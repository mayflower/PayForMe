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
    let id: Int?
    let backend: ProjectBackend
    
    var members: [Int : Person]
    var bills: [Bill]
    
    convenience init(name: String, password: String, backend: ProjectBackend, url: URL) {
        self.init(name: name, password: password, backend: backend, url: url, id: nil)
    }
    
    fileprivate init(name: String, password: String, backend: ProjectBackend, url: URL, id: Int?) {
        self.name = name
        self.password = password
        self.backend = backend
        self.url = url
        self.id = id
        members = [:]
        bills = []
    }
}

struct StoredProject: Codable {
    let name: String
    let password: String
    let url: URL
    let backend: ProjectBackend
    var id: Int?
    
    init(name: String, password: String, url: URL, backend: ProjectBackend) {
        self.name = name
        self.password = password
        self.url = url
        self.backend = backend
        id = nil
    }
    
    init(project: Project) {
        name = project.name
        password = project.password
        url = project.url
        backend = project.backend
        id = project.id
    }
    
    func toProject() -> Project {
        Project(name: name, password: password, backend: backend, url: url, id: id!)
    }
}

extension Project: Equatable {
    static func == (lhs: Project, rhs: Project) -> Bool {
        return lhs.url == rhs.url && lhs.name == rhs.name && lhs.backend == rhs.backend
    }
}

extension StoredProject: Equatable {
    static func == (lhs: StoredProject, rhs: StoredProject) -> Bool {
        return lhs.url == rhs.url && lhs.name == rhs.name && lhs.backend == rhs.backend
    }
}

enum ProjectBackend: Int, Codable, Equatable {
    case cospend = 0
    case iHateMoney = 1
}

let previewProject = Project(name: "TestProject", password: "TestPassword", backend: .cospend, url: URL(string: "https://testserver.de")!, id: 0)
let previewProjects = [
    previewProject,
    Project(name: "test1", password: "test23", backend: .cospend, url: URL(string: "https://testserver.de")!, id: 1),
    Project(name: "test2", password: "test45", backend: .cospend, url: URL(string: "https://testserver.de")!, id: 2),
]
let demoProject = Project(name: "demo", password: "demo", backend: .cospend, url: URL(string: "https://intranet.mayflower.de")!, id: 1)
