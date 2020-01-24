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
    
    func addServer(newServer: Server) {
        let listedServer = servers.first { (listedServer) -> Bool in
            listedServer.url == newServer.url
        }
        // In this case we know the server already
        if let server = listedServer {
            let project = server.projects.first { (listedProject) -> Bool in
                listedProject.name == newServer.projects[0].name
            }
            if project != nil {
                // Project also exists, do nothing
                return
            } else {
                DispatchQueue.main.async {
                    server.projects.append(contentsOf: newServer.projects)
                    StorageService.instance.storeServers(servers: self.servers)
                    self.addingServer = false
                    self.didChange.send(self)
                }
            }
        } else {
            DispatchQueue.main.async {
                self.servers.append(newServer)
                StorageService.instance.storeServers(servers: self.servers)
                self.addingServer = false
                self.didChange.send(self)
            }
        }
    }
    
    func eraseServers() {
        servers = []
        StorageService.instance.storeServers(servers: servers)
        didChange.send(self)
    }
    
    let didChange = PassthroughSubject<ServerListViewModel,Never>()
}
