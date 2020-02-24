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
    var cancellable: Cancellable?
    
    @Published
    var topic = ""
    
    @Published
    var amount = ""
    
    @Published
    var currentProject: Project
    
    init() {
        self.currentProject = manager.currentProject
        self.cancellable = currentProjectChanged
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
    
    func initOwers(currentBill: Bill) -> [Ower] {
        guard !currentBill.owers.isEmpty else {
            return self.currentProject.members.values.map{Ower(id: $0.id, name: $0.name, isOwing: false)}
        }
        
        var owers = currentBill.owers.map {
            Ower(id: $0.id, name: $0.name, isOwing: true)
        }
        let activeOwerIDs = owers.map {
            $0.id
        }
        let inactiveOwers = self.currentProject.members.values.map({
            Ower(id: $0.id, name: $0.name, isOwing: false)
        }).filter {
            !activeOwerIDs.contains($0.id)
        }
        
        owers.append(contentsOf: inactiveOwers)
        
        return owers
    }
    
}
