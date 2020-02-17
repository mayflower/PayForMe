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
    
    private var cancellable: Cancellable?
    
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
            updateCurrentProject()
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
        projects.removeAll {
            $0 == self.currentProject
        }
        projects.append(self.currentProject)
        StorageService.shared.storeProjects(projects: self.projects)
    }
    
    // MARK: Server Communication
    
    @discardableResult func updateCurrentProject() -> Cancellable {
        cancellable?.cancel()
        cancellable = nil
        
        let a = NetworkService.shared.loadBillsPublisher(currentProject)
        let b = NetworkService.shared.loadMembersPublisher(currentProject)
        
        let newCancellable = Publishers.Zip(a, b)
            .map { bills, members in
                return Project(name: self.currentProject.name, password: self.currentProject.password, url: self.currentProject.url, members: members, bills: bills)
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.currentProject, on: self)
        
        cancellable = newCancellable
        return newCancellable
    }
    
    private func sendBillToServer(bill: Bill, update: Bool, completion: @escaping () -> Void) {
        cancellable?.cancel()
        cancellable = nil
        
        if update {
            cancellable = NetworkService.shared.postBillPublisher(bill: bill)
                .sink { success in
                    if success {
                        print("Bill id\(bill.id) updated")
                    } else {
                        print("error updating bill id\(bill.id)")
                    }
                    completion()
            }
        } else {
            cancellable = NetworkService.shared.postBillPublisher(bill: bill)
                .sink { success in
                    if success {
                        print("Bill posted")
                    } else {
                        print("Error posting bill")
                    }
                    completion()
            }
            
        }
    }
    
    private func deleteBillFromServer(bill: Bill) {
        cancellable?.cancel()
        cancellable = nil
        
        cancellable = NetworkService.shared.deleteBillPublisher(bill: bill)
            .sink { success in
                if success {
                    print("Bill successfully deleted")
                    self.updateCurrentProject()
                } else {
                    print("Error deleting bill")
                }
        }
    }
}

extension ProjectManager {
    
    func addProject(_ project: Project) {
        guard !projects.contains(project) else { print("project not added") ; return }
                
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
        self.currentProject.bills.removeAll {
            $0.id == bill.id
        }
        self.deleteBillFromServer(bill: bill)
    }
    
    func setCurrentProject(_ project: Project) {
        guard let project = projects.first (where: {
            $0 == project
        }) else {
            return
        }
        self.currentProject = project
        updateCurrentProject()
        defaults.set(project.id.uuidString, forKey: "projectID")
    }
    
}
