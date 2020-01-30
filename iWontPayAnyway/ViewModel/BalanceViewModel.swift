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
        CospendNetworkService.instance.getMembers(project: project, completion: {_ in 
            self.didChange.send(self)
            self.setBalances()
        })
        CospendNetworkService.instance.loadBills(project: project, completion: {
            self.didChange.send(self)
            self.setBalances()
        })
    }
    
    func setBalances() {
        print(project.bills.count)
        print(project.members.count)
        let payers = Dictionary(grouping: project.bills, by: { $0.payer_id } )
        
        let payersAmount = payers.map {($0.key, $0.value.map{bill in bill.amount}.reduce(0.0, +))}
        balances = payersAmount.compactMap{(id,amount) in
            guard let person = project.members.first(where: {$0.id == id}) else { return nil }
            var color = PersonColor(r: 255, g: 255, b: 255)
            if let savedColor = person.color {
                color = savedColor
            }
            return Balance(id: id, name: person.name, amount: amount, color: color)
        }
        
        let owers = project.bills.flatMap({bill in
            bill.owers.map{ower in (ower.id, bill.amount ,bill.owers.count)}
        })
        
        let owersDict = Dictionary(grouping: owers, by: {$0.0})
        let owingBalance = owersDict.map { ower in (ower.key, ower.value.map{ $0.1 / Double($0.2) }.reduce(0.0, +)) }
        
        balances = balances.map { balance in
            let amount = balance.amount - (owingBalance.first(where: {ower in ower.0 == balance.id})?.1 ?? 0.0)
            return Balance(id: balance.id, name: balance.name, amount: amount, color: balance.color)
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
