//
//  AddProjectQRViewModel.swift
//  PayForMe
//
//  Created by Max Tharr on 02.10.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import SlickLoadingSpinner

class AddProjectQRViewModel: ObservableObject {
    @Published var scannedCode = ""
    @Published var text = ""
    @Published var askForPassword = false
    @Published var passwordText = ""
    
    @Published var url: URL?
    @Published var name = ""
    
    typealias ProjectConnectState = SlickLoadingSpinner.State
    @Published var isProject = ProjectConnectState.notStarted
    
    init() {
        connected.assign(to: &$text)
        passwordCorrect.assign(to: &$isProject)
        isTestingSubject.assign(to: &$isProject)
    }
    
    var isTestingSubject =  PassthroughSubject<ProjectConnectState, Never>()
    
    var passwordCorrect: AnyPublisher<ProjectConnectState, Never> {
        Publishers.CombineLatest3(
            $url
                .compactMap { $0 },
            $name,
            $passwordText
                .debounce(for: 0.5, scheduler: RunLoop.main)
                .compactMap { $0.isEmpty ? nil : $0}
                .removeDuplicates()
        )
            .map { url, name, password in
                self.isTestingSubject.send(.connecting)
                print("\(url) \(name) \(password)")
                return Project(name: name, password: password, backend: .cospend, url: url)
            }
            .flatMap { project in
                NetworkService.shared.testProject(project)
            }
            .map { project, statusCode in
                if statusCode == 200 {
                    ProjectManager.shared.addProject(project)
                    return withAnimation {
                        .right
                    }
                }
                return withAnimation {
                    .wrong
                }
            }
            .eraseToAnyPublisher()
            
    }
    
    var connected: AnyPublisher<String, Never> {
        $scannedCode
            .compactMap { code in
                guard let url = URL(string: code) else { return "Error"}
                let components = url.pathComponents
                if components.count == 4,
                   let url = URL(string: components[1]) {
                    let project = Project(name: components[2], password: components[3], backend: .cospend, url: url)
                    return "\(project)"
                }
                if components.count == 3,
                   let url = URL(string: "https://" + components[1]) {
                    withAnimation {
                        self.url = url
                        self.name = components[2]
                        self.askForPassword.toggle()
                    }
                }
                   
                return nil
            }
            .eraseToAnyPublisher()
    }
}
