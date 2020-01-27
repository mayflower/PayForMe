//
//  ServerList.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 21.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import Foundation
import Combine

class ServerManager: ObservableObject {
    
    init() {
        self.servers = StorageService.instance.loadServers()
        for server in servers {
            print("Server: \(server.url)")
            for project in server.projects {
                print("    Project: \(project.name)")
                CospendNetworkService.instance.getMembers(server: server, project: project, completion: {
                    let answer = $0 ?
                        "🚀🚀🚀 Loaded project \(project)" :
                        "💣💣💣 Error loading project \(project)"
                    print(answer)
                })

            }
        }
        
    }
    
    @Published
    var tabBarState = tabBarItems.BillList {
        didSet {
            if servers.isEmpty && tabBarState != tabBarItems.AddServer{
                tabBarState = tabBarItems.AddServer
            }
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
                    self.tabBarState = tabBarItems.ServerList
                }
            }
        } else {
            DispatchQueue.main.async {
                self.servers.append(newServer)
                StorageService.instance.storeServers(servers: self.servers)
                self.tabBarState = tabBarItems.ServerList
            }
        }
    }
    
    func eraseServers() {
        servers = []
        StorageService.instance.storeServers(servers: servers)
        didChange.send(self)
    }
    
    let didChange = PassthroughSubject<ServerManager,Never>()
    
}
