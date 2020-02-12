//
//  DataManager.swift
//  iWontPayAnyway
//
//  Created by Camille Mainz on 04.02.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import Foundation
import Combine

class ProjectManager: ObservableObject {
    
    private let defaults = UserDefaults.standard
    
    var cancellables = [Cancellable]()
    
    @Published
    private(set) var projects = [Project]()
    
    @Published
    var currentProject: Project = Project(name: "", password: "", url: "")
        
    static let shared = ProjectManager()
    private init() {
        print("init")
        _ = loadData()
        
        if  let id = defaults.string(forKey: "projectID"),
            let project = projects.first(where: {
                $0.id.uuidString == id
            }){
            self.currentProject = project
        }
    }
    
    deinit {
        saveData()
    }
    
    // MARK: Data Persistence
    
    private func loadData() {
        self.projects = StorageService.shared.loadProjects()
    }
    
    private func saveData() {
        StorageService.shared.storeProjects(projects: self.projects)
    }
    
    // MARK: Server Communication
    
    func updateProjects() {
        for project in self.projects {
            updateProject(project)
        }
    }
    
    private func updateProject(_ project: Project) {
        cancellables.append(
            NetworkService.shared.loadBillsPublisher
                .receive(on: RunLoop.main)
                .assign(to: \.currentProject.bills, on: self)
        )
        cancellables.append(
            NetworkService.shared.loadMembersPublisher
                .receive(on: RunLoop.main)
                .assign(to: \.currentProject.members, on: self)
        )
    }
    
    private func sendBillToServer(bill: Bill, update: Bool, completion: @escaping () -> Void) {
        if update {
            cancellables.append(
                NetworkService.shared.postBillPublisher(bill: bill)
                    .sink { success in
                        if success {
                            print("Bill id\(bill.id) updated")
                        } else {
                            print("error updating bill id\(bill.id)")
                        }
                        completion()
                }
            )
        } else {
            cancellables.append(
                NetworkService.shared.postBillPublisher(bill: bill)
                    .sink { success in
                        if success {
                            print("Bill posted")
                        } else {
                            print("Error posting bill")
                        }
                        completion()
                }
                
            )
        }
    }
}

extension ProjectManager {
    
    func addProject(_ project: Project) {
        guard !projects.contains(project) else { print("project not added") ; return }
        
        updateProject(project)
        
        if self.projects.isEmpty {
            self.projects.append(project)
            setCurrentProject(project)
        } else {
            self.projects.append(project)
        }
        
        print("project added")
        saveData()
    }
    
    func deleteProject(_ project: Project) {
        projects.removeAll {
            $0 == project
        }
        if currentProject == project {
            if let nextProject = projects.first {
                setCurrentProject(nextProject)
            } else {
                self.currentProject.bills = []
            }
        }
    }
    
    func saveBill(_ bill: Bill, completion: @escaping () -> Void) {
        if let index = self.currentProject.bills.firstIndex(where: {
            $0.id == bill.id
        }) {
            self.currentProject.bills.remove(at: index)
            self.currentProject.bills.append(bill)
            
            sendBillToServer(bill: bill, update: true, completion: completion)
        } else {
            self.currentProject.bills.append(bill)
            sendBillToServer(bill: bill, update: false, completion: completion)
        }
    }
    
    func deleteBill(_ bill: Bill) {
        
    }
    
    func setCurrentProject(_ project: Project) {
        guard let project = projects.first (where: {
            $0 == project
        }) else {
            return
        }
        self.currentProject = project
        updateProject(project)
        defaults.set(project.id.uuidString, forKey: "projectID")
    }
    
}
