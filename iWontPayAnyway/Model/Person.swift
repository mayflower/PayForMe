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
    var color: PersonColor?
}
struct PersonColor: Codable {
    var r: Int
    var g: Int
    var b: Int
}


let previewPerson = Person(id: 1, weight: 1, name: "Pikachu", activated: true, color: PersonColor(r: 0, g: 255, b: 0))
let previewPersons = [
    previewPerson,
    Person(id: 2, weight: 1, name: "Schiggy", activated: true),
    Person(id: 3, weight: 1, name: "Bisasam", activated: true),
    Person(id: 4, weight: 1, name: "Glumanda", activated: true),
]

