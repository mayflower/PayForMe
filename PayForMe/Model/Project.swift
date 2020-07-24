//
//  Project.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 23.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import Foundation

class Project: Codable, Identifiable {
    let name: String
    let password: String
    let url: URL
    let id: UUID
    let backend: ProjectBackend
    
    var members: [Int : Person]
    var bills: [Bill]
    
    init(name: String, password: String, backend: ProjectBackend, url: URL = URL(string: NetworkService.iHateMoneyURLString)!, members: [Int:Person] = [:], bills: [Bill] = []) {
        self.name = name
        self.password = password
        self.backend = backend
        self.url = url
        
        self.members = members
        self.bills = bills
        
        self.id = UUID()
    }
}

extension Project: Equatable {
    static func == (lhs: Project, rhs: Project) -> Bool {
        return lhs.url == rhs.url && lhs.name == rhs.name && lhs.backend == rhs.backend
    }
}

enum ProjectBackend: Int, Codable, Equatable {
    case cospend = 0
    case iHateMoney = 1
}

let previewProject = Project(name: "TestProject", password: "TestPassword", backend: .cospend, url: URL(string: "https://testserver.de")!, members: previewPersons, bills: previewBills)
let previewProjects = [
    previewProject,
    Project(name: "test1", password: "test23", backend: .cospend, url: URL(string: "https://testserver.de")!),
    Project(name: "test2", password: "test45", backend: .cospend, url: URL(string: "https://testserver.de")!),
]
