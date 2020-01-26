//
//  Person.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 26.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import Foundation

struct Person: Codable, Identifiable {
    var id: Int
    var weight: Int
    var name: String
    var activated: Bool
}

let previewPerson = Person(id: 1, weight: 1, name: "Pikachu", activated: true)
let previewPersons = [
    previewPerson,
    Person(id: 2, weight: 1, name: "Schiggy", activated: true),
    Person(id: 3, weight: 1, name: "Bisasam", activated: true),
    Person(id: 4, weight: 1, name: "Glumanda", activated: true),
]

