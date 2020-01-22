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
    let projects: [String: String]
    
    init(url: String, projects: [String: String]) {
        self.url = url
        self.projects = projects
    }
}
