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

class AddProjectModel: ObservableObject {
    
    
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
    
    var buttonOffset: CGFloat {
        if projectType == .cospend {
            return 220
        } else {
            return 120
        }
    }
        
    static let shared = AddProjectModel()
    
    private init() {
        
    }
    
    func reset() {
        self.serverAddress = ""
        self.projectName = ""
        self.projectPassword = ""
    }
    
    var validatedAddress: AnyPublisher<(ProjectBackend, String?), Never> {
        return Publishers.CombineLatest($projectType, $serverAddress)
            .map {
                type, serverAddress in
                if type == .cospend {
                    return (type, serverAddress)
                } else {
                    return (type, NetworkService.iHateMoneyURLString)
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
                    return Project(name: name, password: password, backend: server.0, url: url)
                } else {
                    return nil
                }
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var validatedServer: AnyPublisher<Bool, Never> {
        return Publishers.FlatMap(upstream: validatedInput, maxPublishers: .unlimited) {
            project in
            return NetworkService.shared.testProject(project)
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
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
            return server ? ValidationState.success : ValidationState.failure
        }
    .eraseToAnyPublisher()
    }
    
    var validationProgress: AnyPublisher<ValidationState, Never> {
        return Publishers.Merge(inputProgress, serverProgress)
        .eraseToAnyPublisher()
    }
}

enum ValidationState {
    case inProgress
    case success
    case failure
//    case empty
}
