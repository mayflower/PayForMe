//
//  BillListViewModel.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 23.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import Foundation
import Combine

class BillListViewModel: ObservableObject {
    
    var manager = ProjectManager.shared
    var cancellables = [AnyCancellable]()
    
    @Published
    var topic = ""
    
    @Published
    var amount = ""
    
    @Published
    var currentProject: Project
    
    init() {
        self.currentProject = manager.currentProject
        self.cancellables.append(currentProjectChanged)
    }
    
    var currentProjectChanged: AnyCancellable {
        manager.$currentProject
            .assign(to: \.currentProject, on: self)
    }
        
    var validatedInput: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest($topic, validatedAmount)
            .map { topic, validatedAmount in
                return !topic.isEmpty && validatedAmount
            }
            .eraseToAnyPublisher()
    }
    
    var validatedAmount: AnyPublisher<Bool, Never> {
        return $amount.map { amount in
            return Double(amount) != nil
        }
        .eraseToAnyPublisher()
    }
    
}
