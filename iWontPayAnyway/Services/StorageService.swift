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
    
    private let serversPath = getFilePath()
    
    static let instance = StorageService()
    
    private init() {
        print("Storage service initialized")
    }
    
    func storeServers(servers: [Server]) {
        let data  = try? encoder.encode(servers)
        try? data?.write(to: serversPath)
    }
    
    func loadServers() -> [Server]{
        guard let data = try? Data(contentsOf: serversPath) else {
            print("Could not open file URL")
            return [Server]()
        }
        let servers = try? decoder.decode([Server].self, from: data)
        if let servers = servers {
            return servers
        } else {
            return [Server]()
        }
    }
}

func getFilePath() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Server.json")
}
