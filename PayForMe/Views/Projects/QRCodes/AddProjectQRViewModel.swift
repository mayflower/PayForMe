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
    
    typealias ProjectConnectState = LoadingState
    @Published var isProject = ProjectConnectState.notStarted
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        foundCodeSink.store(in: &subscriptions)
        passwordCorrect.assign(to: &$isProject)
        isTestingSubject.assign(to: &$isProject)
    }
    
    convenience init(openedByURL: URL?) {
        self.init()
        scannedCode = openedByURL
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
                        .success
                    }
                }
                return withAnimation {
                    .failure
                }
            }
            .eraseToAnyPublisher()
            
    }
    
    var urlString: String {
        url?.absoluteString ?? "URL wrong, please scan right barcode"
    }
    
    var foundCode: AnyPublisher<URL, Never> {
        $scannedCode
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    var foundCodeSink: AnyCancellable {
        foundCode
            .sink { codedUrl in
                let projectData = codedUrl.decodeQRCode()
                guard let url = projectData.server, let name = projectData.project else { return }
                if let password = projectData.passwd {
                    self.isTestingSubject.send(.connecting)
                    let project = Project(name: name, password: password, backend: .cospend, url: url)
                    NetworkService.shared.testProject(project)
                        .asUIPublisher
                        .sink(receiveValue: {
                            project, code in
                            if code == 200 {
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: .seconds(1))) {
                                    ProjectManager.shared.addProject(project)
                                }
                                self.isTestingSubject.send(.success)
                            } else {
                                self.isTestingSubject.send(.failure)
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
