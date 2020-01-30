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
    var project: Project {
        didSet {
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
                return Balance(id: id, name: person.name, amount: amount, color: color)}
        }
    }
    
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
        })
        CospendNetworkService.instance.loadBills(project: project, completion: {
            self.didChange.send(self)
        })
    }
    
    let didChange = PassthroughSubject<BalanceViewModel,Never>()
}

struct Balance: Identifiable {
    let id: Int
    let name: String
    let amount: Double
    let color: PersonColor
}
