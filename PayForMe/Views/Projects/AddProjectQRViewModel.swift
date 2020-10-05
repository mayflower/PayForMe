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
    @Published var scannedCode: URL?
    @Published var text = ""
    @Published var askForPassword = false
    @Published var passwordText = ""
    
    @Published var url: URL?
    @Published var name = ""
    
    typealias ProjectConnectState = SlickLoadingSpinner.State
    @Published var isProject = ProjectConnectState.notStarted
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        foundCodeSink.store(in: &subscriptions)
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
    
    var foundCode: AnyPublisher<URL, Never> {
        $scannedCode
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    var foundCodeSink: AnyCancellable {
        foundCode
            .sink { codedUrl in
                let (optionalUrl, optionalName, optionalPassword) = codedUrl.decodeMoneyBusterString()
                guard let url = optionalUrl, let name = optionalName else { return }
                if let password = optionalPassword {
                    self.isTestingSubject.send(.connecting)
                    let project = Project(name: name, password: password, backend: .cospend, url: url)
                    NetworkService.shared.testProject(project)
                        .asUIPublisher
                        .sink(receiveValue: {
                            project, code in
                            if code == 200 {
                                ProjectManager.shared.addProject(project)
                                self.isTestingSubject.send(.right)
                            } else {
                                self.isTestingSubject.send(.wrong)
                            }
                        }).store(in: &self.subscriptions)
                } else {
                    withAnimation {
                        self.url = url
                        self.name = name
                        self.askForPassword.toggle()
                    }
                }
            }
    }
}
