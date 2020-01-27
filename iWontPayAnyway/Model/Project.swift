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
    let url: String
    
    init(name: String, password: String, url: String) {
        self.name = name
        self.password = password
        self.url = url
    }
    var members: [Person] = []
    
    var bills: [Bill] = []
}

let previewProject = Project(name: "TestProject", password: "TestPassword", url: "https://testserver.de")
let previewProjects = [
    previewProject,
    Project(name: "test1", password: "test23", url: "https://testserver.de"),
    Project(name: "test2", password: "test45", url: "https://testserver.de"),
]
