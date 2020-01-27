//
//  StorageService.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 22.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import Foundation

class StorageService {
    
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    private let projectsPath = getFilePath()
    
    static let instance = StorageService()
    
    private init() {
        print("Storage service initialized")
    }
    
    func storeProjects(projects: [Project]) {
        let data  = try? encoder.encode(projects)
        try? data?.write(to: projectsPath)
    }
    
    func loadProjects() -> [Project]{
        guard let data = try? Data(contentsOf: projectsPath) else {
            print("Could not open file URL")
            return [Project]()
        }
        let projects = try? decoder.decode([Project].self, from: data)
        if let projects = projects {
            return projects
        } else {
            return [Project]()
        }
    }
}

func getFilePath() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Projects.json")
}
