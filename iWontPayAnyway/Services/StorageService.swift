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
        guard let encodedData = try? encoder.encode(projects) else {
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
        let projects = try? decoder.decode([Project].self, from: data)
        if let projects = projects {
            print("data loaded")
            return projects
        } else {
            print("💣💣💣 Could not decode saved Data, will be overriden -> probably the model changed")
            return [Project]()
        }
    }
}
