//
//  Project.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 23.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import Foundation
import CoreStore

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
    
    fileprivate init(name: String, password: String, backend: ProjectBackend, url: URL, id: UUID) {
        self.name = name
        self.password = password
        self.backend = backend
        self.url = url
        self.id = id
        members = [:]
        bills = []
    }
}

struct StoredProject: Codable, Identifiable {
    let name: String
    let password: String
    let url: URL
    let id: UUID
    let backend: ProjectBackend
    
    let dbVersion: Int
    
    init(project: Project) {
        name = project.name
        password = project.password
        url = project.url
        id = project.id
        backend = project.backend
        dbVersion = 2
    }
    
    func toProject() -> Project {
        Project(name: name, password: password, backend: backend, url: url, id: id)
    }
}


class StoreProject: CoreStoreObject {
    
    @Field.Stored("id")
    var id: String = ""
    
    @Field.Coded("url", coder: FieldCoders.Json.self)
    var url: URL = URL.init(string: "test")!
    
    @Field.Stored("name")
    var name: String = ""
    
    @Field.Stored("password")
    var password: String = ""
    
    @Field.Coded("backend", coder: FieldCoders.Json.self)
    var backend: ProjectBackend = ProjectBackend.cospend
    
    func toProject() -> Project {
        Project(name: name, password: password, backend: backend, url: url, id: UUID(uuidString: id)!)
    }
    
    static func == (lhs: StoreProject, rhs: StoreProject) -> Bool {
        lhs.backend == rhs.backend &&
            lhs.name == rhs.name &&
            lhs.password == rhs.password &&
            lhs.url == rhs.url
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
