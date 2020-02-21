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
    var serverAddress = ""
    
    @Published
    var projectName = ""
    
    @Published
    var projectPassword = ""
    
//    @Published
    var networkTestInProgress = false {
        didSet {
            print(self.networkTestInProgress)
        }
    }
    
    var cancellable: AnyCancellable?
    
    
    init() {
        cancellable = NetworkService.shared.networkActivityPublisher.assign(to: \.networkTestInProgress, on: self)
    }
    var validatedAddress: AnyPublisher<String, Never> {
        return Publishers.CombineLatest($projectType, $serverAddress)
            .map {
                type, serverAddress in
                if type == .cospend {
                    return serverAddress
                } else {
                    return "https://ihatemoney.org"
                }
        }
        .eraseToAnyPublisher()
    }
    
    var validatedInput: AnyPublisher<Project, Never> {
        return Publishers.CombineLatest3(validatedAddress, $projectName, $projectPassword)
            .debounce(for: 1, scheduler: DispatchQueue.main)
            .compactMap { address, name, password in
                if address.isValidURL && !name.isEmpty && !password.isEmpty {
                    guard let url = URL(string: address) else { return nil }
                    return Project(name: name, password: password, url: url)
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
}
