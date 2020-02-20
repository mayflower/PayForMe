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
    
    init(name: String, password: String, url: URL, members: [Person] = [], bills: [Bill] = []) {
        self.name = name
        self.password = password
        self.url = url
        
        self.members = members
        self.bills = bills
        
        self.id = UUID()
        
        if url.relativeString.lowercased().contains("ihatemoney") {
            self.backend = .iHateMoney
        } else {
            self.backend = .cospend
        }
    }
    var members: [Person]
    
    var bills: [Bill]
}

extension Project: Equatable {
    static func == (lhs: Project, rhs: Project) -> Bool {
        return (lhs.id == rhs.id) || (lhs.url == rhs.url && lhs.name == rhs.name)
    }
}

enum ProjectBackend: Int, Codable {
    case cospend = 0
    case iHateMoney = 1
}

let previewProject = Project(name: "TestProject", password: "TestPassword", url: URL(string: "https://testserver.de")!)
let previewProjects = [
    previewProject,
    Project(name: "test1", password: "test23", url: URL(string: "https://testserver.de")!),
    Project(name: "test2", password: "test45", url: URL(string: "https://testserver.de")!),
]
