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
    var currentProject: Project = Project(name: "", password: "", backend: .iHateMoney)
    
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
    
    private func createProjectOnServer(_ project: Project, email: String, completion: @escaping () -> Void) {
        cancellable?.cancel()
        cancellable = nil
        
        cancellable = NetworkService.shared.createProjectPublisher(project, email: email)
            .sink { success in
                if success {
                    print("Project \(project.name) created successfully")
                } else {
                    print("Error creating project \(project.name)")
                }
                 completion()
            }
    }
    
    @discardableResult func updateCurrentProject() -> Cancellable {
        cancellable?.cancel()
        cancellable = nil
        
        let a = NetworkService.shared.loadBillsPublisher(currentProject)
        let b = NetworkService.shared.loadMembersPublisher(currentProject)
        
        let newCancellable = Publishers.Zip(a, b)
            .map { bills, members in
                return Project(name: self.currentProject.name, password: self.currentProject.password, backend: self.currentProject.backend, url: self.currentProject.url, members: members, bills: bills)
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
            cancellable = NetworkService.shared.updateBillPublisher(bill: bill)
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
    
    private func deleteBillFromServer(bill: Bill, completion: @escaping () -> Void) {
        cancellable?.cancel()
        cancellable = nil
        
        cancellable = NetworkService.shared.deleteBillPublisher(bill: bill)
            .sink { success in
                if success {
                    print("Bill successfully deleted")
                } else {
                    print("Error deleting bill")
                }
                completion()
        }
    }
    
    private func sendMemberToServer(_ member: Person, update: Bool, completion: @escaping () -> Void) {
        cancellable?.cancel()
        cancellable = nil
        
        if update {
            cancellable = NetworkService.shared.updateMemberPublisher(member: member)
                .sink { success in
                    if success {
                        print("Member id\(member.id) updated")
                    } else {
                        print("Error updating Member")
                    }
                    completion()
            }
        } else {
            cancellable = NetworkService.shared.createMemberPublisher(name: member.name)
                .sink { success in
                    if success {
                        print("Member successfully created")
                    } else {
                        print("Error creating member")
                    }
                    completion()
            }
        }
    }
    
    private func deleteMemberFromServer(_ member: Person, completion: @escaping () -> Void) {
        cancellable?.cancel()
        cancellable = nil
        
        cancellable = NetworkService.shared.deleteMemberPublisher(member: member)
            .sink { success in
                if success {
                    print("Member id\(member.id) successfully deleted")
                } else {
                    print("Error deleting member")
                }
                completion()
        }
    }
}

extension ProjectManager {
    
    func createProject(_ project: Project, email: String, completion: @escaping () -> Void) {
        guard !projects.contains(project) else { print("project duplicate") ; return }
        
        self.createProjectOnServer(project, email: email, completion: completion)
    }
    
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
        if let _ = self.currentProject.bills.firstIndex(where: {
            $0.id == bill.id
        }) {
            sendBillToServer(bill: bill, update: true, completion: completion)
        } else {
            sendBillToServer(bill: bill, update: false, completion: completion)
        }
    }
    
    func deleteBill(_ bill: Bill, completion: @escaping () -> Void) {
        self.currentProject.bills.removeAll {
            $0.id == bill.id
        }
        self.deleteBillFromServer(bill: bill, completion: completion)
    }
    
    func addMember(_ name: String, completion: @escaping () -> Void) {
        let newMember = Person(id: -1, weight: -1, name: name, activated: true, color: nil)
        self.sendMemberToServer(newMember, update: false, completion: completion)
    }
    
    func updateMember(_ member: Person, completion: @escaping () -> Void) {
        self.sendMemberToServer(member, update: true, completion: completion)
    }
    
    func deleteMember(_ member: Person, completion: @escaping () -> Void) {
        self.deleteMemberFromServer(member, completion: completion)
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
