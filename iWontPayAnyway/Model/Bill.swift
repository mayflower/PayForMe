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
    var date: String
    var payer_id: Int
    var owers: [Person]
    var `repeat`: String
    var lastchanged: Int
    
}

struct Person: Codable, Identifiable {
    var id: Int
    var weight: Int
    var name: String
    var activated: Bool
}

let previewBills = [
    Bill(id: 1, amount: 5, what: "Erdnüsse", date: "21-12-2019", payer_id: 1, owers: [
        Person(id: 1, weight: 1, name: "Rolle", activated: true),
        Person(id: 2, weight: 1, name: "Rolle2", activated: true),
        Person(id: 3, weight: 1, name: "Rolle4", activated: true)
    ], repeat: "n", lastchanged: 1231234),
    Bill(id: 2, amount: 5, what: "Nochmal Erdnüsse", date: "21-12-2019", payer_id: 1, owers: [
        Person(id: 1, weight: 1, name: "Rolle", activated: true),
        Person(id: 2, weight: 1, name: "Rolle2", activated: true),
        Person(id: 3, weight: 1, name: "Rolle4", activated: true)
    ], repeat: "n", lastchanged: 1231234),
    
]

let previewPerson = Person(id: 1, weight: 1, name: "TestUser", activated: true)
