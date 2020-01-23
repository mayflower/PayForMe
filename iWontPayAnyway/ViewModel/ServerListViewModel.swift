//
//  ServerList.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 21.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import Foundation
import Combine

class ServerListViewModel: ObservableObject {
    
    init() {
        self.servers = StorageService.instance.loadServers()
        for server in servers {
            print("Server: \(server.url)")
            for project in server.projects {
                print("    Project: \(project.name)")
            }
        }
    }
    
    func showServerAdding() -> Bool {
        return servers.isEmpty || addingServer
    }
    
    @Published
    var addingServer = false {
        didSet {
            didChange.send(self)
        }
    }
    
    @Published
    var servers = [Server]() {
        didSet {
            didChange.send(self)
        }
    }
    
    func addServer(server: Server) {
        servers.append(server)
        StorageService.instance.storeServers(servers: servers)
        addingServer = false
        didChange.send(self)
    }
    
    func eraseServers() {
        servers = []
        StorageService.instance.storeServers(servers: servers)
        didChange.send(self)
    }
    
    let didChange = PassthroughSubject<ServerListViewModel,Never>()
}
