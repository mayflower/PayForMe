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
    var addOrCreate = 0
    
    @Published
    var serverAddress = ""
    
    @Published
    var projectName = ""
    
    @Published
    var projectPassword = ""
    
    @Published
    var emailAddr = ""
    
    func reset() {
        self.serverAddress = ""
        self.projectName = ""
        self.projectPassword = ""
    }
    
    var validatedAddress: AnyPublisher<(ProjectBackend, String?), Never> {
        return Publishers.CombineLatest($projectType, $serverAddress)
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
    
    var validatedServer: AnyPublisher<Int, Never> {
        return Publishers.FlatMap(upstream: validatedInput, maxPublishers: .unlimited) {
            project in
            return NetworkService.shared.testProject(project)
        }
        .map {project, code in
            code
        }
        .removeDuplicates()
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    var errorTextPublisher: AnyPublisher<String, Never> {
        return Publishers.Map(upstream: validatedServer) {
            statusCode in
            if statusCode != 200 {
                switch statusCode {
                    case -1:
                        return "Could not find server"
                    case 401:
                        return "Unauthorized: Wrong project id/pw"
                    default:
                        return "Server error: \(statusCode)"
                }
            }
            return ""
        }.eraseToAnyPublisher()
    }
    
    private var inputProgress: AnyPublisher<ValidationState, Never> {
        return Publishers.Map(upstream: validatedInput) {
            input in
            return ValidationState.inProgress
        }
        .eraseToAnyPublisher()
    }
    
    private var serverProgress: AnyPublisher<ValidationState, Never> {
        return Publishers.Map(upstream: validatedServer) {
            server in
            return server == 200 ? ValidationState.success : ValidationState.failure
        }
        .eraseToAnyPublisher()
    }
    
    private var createProject: AnyPublisher<ValidationState, Never> {
        return Publishers.CombineLatest4(validatedInput,$addOrCreate,$projectType, $emailAddr)
            .compactMap {
                input, addOrCreate, backend, email in
                if addOrCreate == 1 && backend == .iHateMoney && email.isValidEmail {
                    return ValidationState.success
                }
                return nil
        }
        .eraseToAnyPublisher()
    }
    
    var validationProgress: AnyPublisher<ValidationState, Never> {
        return Publishers.Merge3(inputProgress, serverProgress, createProject)
            .eraseToAnyPublisher()
    }
}

enum ValidationState {
    case inProgress
    case success
    case failure
    //    case empty
}
