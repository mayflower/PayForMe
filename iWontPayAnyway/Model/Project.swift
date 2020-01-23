//
//  Project.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 23.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import Foundation

class Project: Codable {
    let name: String
    let password: String
    
    init(name: String, password: String) {
        self.name = name
        self.password = password
    }
    
    let members: [Person] = []
    let bills: [Bill] = []
}
