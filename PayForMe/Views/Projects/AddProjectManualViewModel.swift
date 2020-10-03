//
//  AddServerModel.swift
//  iWontPayAnyway
//
//  Created by Camille Mainz on 05.02.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import Foundation
import UIKit
import Combine

class AddProjectManualViewModel: ObservableObject {
    
    
    @Published
    var projectType = ProjectBackend.cospend
    
    @Published
    var serverAddress = ""
    
    @Published
    var projectName = ""
    
    @Published
    var projectPassword = ""
    
    @Published var validationProgress = LoadingState.notStarted
    
    @Published var errorText = ""
    
    private var lastProjectTestedSuccessfully: Project?
    
    init() {
        validatedInput.map { _ in LoadingState.connecting }.assign(to: &$validationProgress)
        validatedServer.map { $0 == 200 ? LoadingState.right : LoadingState.wrong }.assign(to: &$validationProgress)
        errorTextPublisher.assign(to: &$errorText)
    }
    
    func reset() {
        self.serverAddress = ""
        self.projectName = ""
        self.projectPassword = ""
    }
    
    func addProject() {
        guard let project = lastProjectTestedSuccessfully else { return }
        ProjectManager.shared.addProject(project)
    }
    
    var serverAddressFormatted: AnyPublisher<String, Never> {
        $serverAddress
            .map { $0.hasPrefix("https://") ? $0 : "https://\($0)" }
            .map { unformatted in
            if let index = unformatted.index(of: "/index.php") {
                if let url = URL(string: unformatted) {
                    let components = url.pathComponents
                    if components.count == 6 {
                        self.projectPassword = components[5]
                        self.projectName = components[4]
                    }
                    if components.count == 5 {
                        self.projectName = components[4]
                    }
                }
                return String(unformatted[..<index])
            }
            return unformatted
        }.eraseToAnyPublisher()
    }
    
    private var validatedAddress: AnyPublisher<(ProjectBackend, String?), Never> {
        return Publishers.CombineLatest($projectType, serverAddressFormatted)
            .map {
                type, serverAddress in
                if type == .iHateMoney && serverAddress == "" {
                    return (type, NetworkService.iHateMoneyURLString)
                } else {
                    return (type, serverAddress)
                }
            }
            .eraseToAnyPublisher()
    }
    
    var validatedInput: AnyPublisher<Project, Never> {
        return Publishers.CombineLatest3(validatedAddress, $projectName, $projectPassword)
            .debounce(for: 1, scheduler: DispatchQueue.main)
            .compactMap { server, name, password in
                if let address = server.1, address.isValidURL && !name.isEmpty && !password.isEmpty {
                    guard let url = URL(string: address) else { return nil }
                    return Project(name: name.lowercased(), password: password, backend: server.0, url: url)
                } else {
                    return nil
                }
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    private var validatedServer: AnyPublisher<Int, Never> {
        validatedInput.flatMap {
            project in
            return NetworkService.shared.testProject(project)
        }
        .map {project, code in
            self.lastProjectTestedSuccessfully = project
            return code
        }
        .removeDuplicates()
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    private var errorTextPublisher: AnyPublisher<String, Never> {
        validatedServer.map {
            statusCode in
            switch statusCode {
                case 200:
                    return ""
                case -1:
                    return "Could not find server"
                case 401:
                    return "Unauthorized: Wrong project id/pw"
                default:
                    return "Server error: \(statusCode)"
            }
        }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }
}
