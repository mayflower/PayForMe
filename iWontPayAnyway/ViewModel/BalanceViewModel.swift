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
    var balances = [Balance]() {
        didSet {
            didChange.send(self)
        }
    }
    
    init(project: Project) {
        let payers = Dictionary(grouping: project.bills, by: { $0.payer_id } )
        
        let payersAmount = payers.map {($0.key, $0.value.map{bill in bill.amount}.reduce(0.0, +))}
        balances = payersAmount.map{(id,amount) in Balance(id: id,name: project.members.first{$0.id == id}?.name ?? "unknown",amount: amount)}
    }
    
    let didChange = PassthroughSubject<BalanceViewModel,Never>()
}

struct Balance: Identifiable {
    let id: Int
    let name: String
    let amount: Double
}
