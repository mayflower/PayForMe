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
    
    @Published
    var projects = [Project]() {
        didSet {
            didChange.send(self)
        }
    }
    
    
    
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
    
    func addProject(newProject: Project) {
        
        guard !projects.contains(newProject) else {
            print("Project already exists")
            return
        }
        
        DispatchQueue.main.async {
            self.projects.append(newProject)
            StorageService.instance.storeProjects(projects: self.projects)
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
