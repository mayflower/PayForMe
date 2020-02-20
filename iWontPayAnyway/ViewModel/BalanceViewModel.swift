//
//  BalanceViewModel.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 29.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

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
        balances = currentProject.members.values.map {
            member in
            let paid = currentProject.bills.filter { $0.payer_id == member.id }.map { $0.amount }.reduce(0.0, +)
            let owes = currentProject.bills.compactMap { bill in
                bill.owers.first { ower in ower.id == member.id } == nil ? nil : bill.amount / Double( bill.owers.count) }
                .reduce(0.0, -)
            var color = Color.standardColorById(id: member.id)
            if let pc = member.color {
                color = Color(pc)
            }
            return Balance(id: member.id, name: member.name, amount: paid + owes, color: color)
        }
    }
}

struct Balance: Identifiable {
    let id: Int
    let name: String
    var amount: Double
    let color: Color
}
