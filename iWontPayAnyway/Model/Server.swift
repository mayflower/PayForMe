//
//  Server.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 21.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import Foundation

class Server: Codable {
    let url: String
    let projects: [Project]
    
    init(url: String, projects: [Project]) {
        self.url = url
        self.projects = projects
    }
}
