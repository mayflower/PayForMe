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
    
    private let dispatchGroup = DispatchGroup()
    private let notificationCenter = NotificationCenter.default
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
    
    private func sendBillToServer(bill: Bill, update: Bool) {
        if update {
            NetworkService.shared.updateBill(project: currentProject, bill: bill) { (success, _) in
                if success {
                    self.saveData()
                } else {
                    self.currentProject.bills.removeAll {
                        $0.id == bill.id
                    }
                }
            }
        } else {
            NetworkService.shared.postBill(project: currentProject, bill: bill) { (success, id) in
                guard success else {
                    self.currentProject.bills.removeAll {
                        $0.id == bill.id
                    }
                    return
                }
                
                guard let id = id, let index = self.currentProject.bills.firstIndex(where: { $0.id == bill.id }) else {
                    return
                }
                
                self.currentProject.bills[index].id = id
                self.saveData()
            }
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
    
    func saveBill(_ bill: Bill) {
        if let index = self.currentProject.bills.firstIndex(where: {
            $0.id == bill.id
        }) {
            self.currentProject.bills.remove(at: index)
            self.currentProject.bills.append(bill)
            
            sendBillToServer(bill: bill, update: true)
        } else {
            self.currentProject.bills.append(bill)
            sendBillToServer(bill: bill, update: false)
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
        self.currentProject.bills = project.bills
        defaults.set(project.id.uuidString, forKey: "projectID")
    }
    
}
