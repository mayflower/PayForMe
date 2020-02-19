//
//  Bill.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 21.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import Foundation

struct Bill: Codable, Identifiable {
    
    var id: Int
    var amount: Double
    var what: String
    var date: Date
    var payer_id: Int
    var owers: [Person]
    var `repeat`: String?
    var lastchanged: Int?
 
    var params: [String: String] {
        return [
            "date": DateFormatter.cospend.string(from: self.date),
            "what": self.what,
            "payer": self.payer_id.description,
            "amount": self.amount.description,
            "payed_for": self.owers.map{$0.id.description}.joined(separator: ","),
            "repeat": "n",
            "paymentmode": "n",
            "categoryid": "0"
        ]
    }
    
}

let date = DateFormatter.cospend.date(from: "2019-12-21")!

let previewBills = [
    Bill(id: 1, amount: 5, what: "Erdnüsse", date: date, payer_id: 1, owers: [
        Person(id: 1, weight: 1, name: "Rolle", activated: true),
        Person(id: 2, weight: 1, name: "Rolle2", activated: true),
        Person(id: 3, weight: 1, name: "Rolle4", activated: true)
    ], repeat: "n", lastchanged: 1231234),
    Bill(id: 2, amount: 5, what: "Nochmal Erdnüsse", date: date, payer_id: 1, owers: [
        Person(id: 1, weight: 1, name: "Rolle", activated: true),
        Person(id: 2, weight: 1, name: "Rolle2", activated: true),
        Person(id: 3, weight: 1, name: "Rolle4", activated: true)
    ], repeat: "n", lastchanged: 1231234),
    Bill(id: 3, amount: 5, what: "Nochmal Erdnüsse", date: date, payer_id: 2, owers: [
        Person(id: 1, weight: 1, name: "Rolle", activated: true),
        Person(id: 2, weight: 1, name: "Rolle2", activated: true),
        Person(id: 3, weight: 1, name: "Rolle4", activated: true)
    ], repeat: "n", lastchanged: 1231234),
    Bill(id: 4, amount: 5, what: "Nochmal Erdnüsse", date: date, payer_id: 3, owers: [
        Person(id: 1, weight: 1, name: "Rolle", activated: true),
        Person(id: 2, weight: 1, name: "Rolle2", activated: true),
        Person(id: 3, weight: 1, name: "Rolle4", activated: true)
    ], repeat: "n", lastchanged: 1231234),
    Bill(id: 5, amount: 5, what: "Nochmal Erdnüsse", date: date, payer_id: 1, owers: [
        Person(id: 1, weight: 1, name: "Rolle", activated: true),
        Person(id: 2, weight: 1, name: "Rolle2", activated: true),
        Person(id: 3, weight: 1, name: "Rolle4", activated: true)
    ], repeat: "n", lastchanged: 1231234),
    
]
