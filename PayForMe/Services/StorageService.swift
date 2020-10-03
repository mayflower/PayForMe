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
    
    private var filePath: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Projects.json")
    }
    
    static let shared = StorageService()
    
    private init() {
        print("Storage service initialized")
    }
    
    func storeProjects(projects: [Project]) {
        let storedProjects = projects.map { StoredProject(project: $0) }
        
        guard let encodedData = try? encoder.encode(storedProjects) else {
            print("data not saved")
            return
        }
        do {
            try encodedData.write(to: filePath)
            print("data saved")
        } catch let error {
            print("data not saved")
            print(error)
        }
    }
    
    func loadProjects() -> [Project]{
        guard let data = try? Data(contentsOf: filePath) else {
            print("Could not open file URL")
            return [Project]()
        }
        //Test legacyVersion
        if let projects = try? decoder.decode([Project].self, from: data) {
            print("data loaded legacy, will save as new")
            storeProjects(projects: projects)
            return projects
        }
        //Try new version
        if let projects = try? decoder.decode([StoredProject].self, from: data) {
            print("data loaded v2")
            return projects.map { $0.toProject() }
        }
        print("💣💣💣 Could not decode saved Data, will be overriden -> probably the model changed")
        return [Project]()
    }
}
