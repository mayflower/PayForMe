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
    
    @Published
    var selectedProject: Project?
    
    init() {
        self.projects = StorageService.shared.loadProjects()
        for project in projects {
            print("Server: \(project.url)")
            print("    Project: \(project.name)")
        }
        if !projects.isEmpty {
            selectedProject = projects[0]
        }
    }
    
    func addProject(newProject: Project) {
        
        guard !projects.contains(newProject) else {
            print("Project already exists")
            return
        }
        
        DispatchQueue.main.async {
            self.projects.append(newProject)
            StorageService.shared.storeProjects(projects: self.projects)
        }
    }
    
    func removeProject(project: Project) {
        let updatedProjects = projects.filter {
            $0 != project
        }
        if project == selectedProject {
            if projects.isEmpty {
                selectedProject = nil
            } else {
                selectedProject = projects[0]
            }
            didChange.send(self)
        }
        DispatchQueue.main.async {
            self.projects = updatedProjects
            StorageService.shared.storeProjects(projects: updatedProjects)
        }
    }
    
    let didChange = PassthroughSubject<ServerManager,Never>()
    
}
