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
        self.projects = StorageService.instance.loadProjects()
        for project in projects {
            print("Server: \(project.url)")
            print("    Project: \(project.name)")
            CospendNetworkService.instance.getMembers(project: project, completion: {
                let answer = $0 ?
                    "🚀🚀🚀 Loaded project \(project)" :
                "💣💣💣 Error loading project \(project)"
                print(answer)
            })
            
        }
        
    }
    
    @Published
    var tabBarState = tabBarItems.BillList {
        didSet {
            if projects.isEmpty && tabBarState != tabBarItems.AddServer{
                tabBarState = tabBarItems.AddServer
            }
            didChange.send(self)
        }
    }
    
    @Published
    var projects = [Project]() {
        didSet {
            didChange.send(self)
        }
    }
    
    func addProject(newProject: Project) {
        
        guard !projects.contains(newProject) else {
            return
        }
        
        DispatchQueue.main.async {
            self.projects.append(newProject)
            StorageService.instance.storeProjects(projects: self.projects)
            self.tabBarState = tabBarItems.ServerList
        }
    }
    
    func removeProject(project: Project) {
        let updatedProjects = projects.filter {
            $0 != project
        }
        DispatchQueue.main.async {
            self.projects = updatedProjects
            StorageService.instance.storeProjects(projects: updatedProjects)
        }
    }
    
    func eraseServers() {
        projects = []
        StorageService.instance.storeProjects(projects: self.projects)
        didChange.send(self)
    }
    
    let didChange = PassthroughSubject<ServerManager,Never>()
    
}
