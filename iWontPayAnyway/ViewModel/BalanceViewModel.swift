//
//  BalanceViewModel.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 29.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import Foundation
import Combine

class BalanceViewModel: ObservableObject {
    
    var manager = ProjectManager.shared
    var cancellable: Cancellable?
    
    @Published
    var currentProject: Project
    
    @Published
    var balances = [Balance]()
    
    init() {
        self.currentProject = manager.currentProject
        self.setBalances()
        
        self.cancellable = currentProjectChanged
    }
    
    var currentProjectChanged: AnyCancellable {
        manager.$currentProject
            .sink {
                self.currentProject = $0
                self.setBalances()
            }
    }
    
    func setBalances() {
        balances = currentProject.members.map {
            member in
            let paid = currentProject.bills.filter { $0.payer_id == member.id }.map { $0.amount }.reduce(0.0, +)
            let owes = currentProject.bills.compactMap { bill in
                bill.owers.first { ower in ower.id == member.id } == nil ? nil : bill.amount / Double( bill.owers.count) }
                .reduce(0.0, -)
            return Balance(id: member.id, name: member.name, amount: paid + owes, color: member.color ?? PersonColor(r: 255, g: 255, b: 255) )
        }
    }
}

struct Balance: Identifiable {
    let id: Int
    let name: String
    var amount: Double
    let color: PersonColor
}
