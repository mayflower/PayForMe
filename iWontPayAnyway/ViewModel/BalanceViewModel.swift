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
    
    @Published
    var project: Project
    
    @Published
    var balances = [Balance]() {
        didSet {
            didChange.send(self)
        }
    }
    
    init(project: Project) {
        self.project = project
        self.setBalances()
//        NetworkingManager.shared.getMembers(project: project, completion: {(_, _) in
//            self.didChange.send(self)
//            self.setBalances()
//        })
//        NetworkingManager.shared.loadBills(project: project, completion: {
//            self.didChange.send(self)
//            self.setBalances()
//        })
    }
    
    func setBalances() {
        balances = project.members.map {
            member in
            let paid = project.bills.filter { $0.payer_id == member.id }.map { $0.amount }.reduce(0.0, +)
            let owes = project.bills.compactMap { bill in
                bill.owers.first { ower in ower.id == member.id } == nil ? nil : bill.amount / Double( bill.owers.count) }
                .reduce(0.0, -)
            return Balance(id: member.id, name: member.name, amount: paid + owes, color: member.color ?? PersonColor(r: 255, g: 255, b: 255) )
        }
    }
    
    let didChange = PassthroughSubject<BalanceViewModel,Never>()
}

struct Balance: Identifiable {
    let id: Int
    let name: String
    var amount: Double
    let color: PersonColor
}
