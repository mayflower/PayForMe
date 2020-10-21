//
//  StorageService.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 22.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import Foundation
import GRDB

class StorageService {
    
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    private let databasePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    private var legacyFilePath: URL {
        return databasePath.appendingPathComponent("Projects.json")
    }

    
    private let dbQueue: DatabaseQueue
    
    init() {
        do {
            dbQueue = try DatabaseQueue(path: databasePath.appendingPathComponent("payforme.sqlite").path)
            try dbQueue.write { db in
                try db.create(table: "storedProject", ifNotExists: true) { table in
                    table.autoIncrementedPrimaryKey("id")
                    table.column("name")
                    table.column("password")
                    table.column("url")
                    table.column("backend")
                }
                try db.create(table: "bill", ifNotExists: true) { table in
                    table.primaryKey(["id"])
                    table.column("id")
                    table.column("amount")
                    table.column("what")
                    table.column("date")
                    table.column("payer_id")
                    table.column("owers")
                    table.column("repeat")
                    table.column("lastChanged")
                }
                try db.create(table: "person", ifNotExists: true) { table in
                    table.primaryKey(["id"])
                    table.column("id")
                    table.column("weight")
                    table.column("name")
                    table.column("activated")
                    table.column("payer_id")
                    table.column("color")
                }
            }
        } catch let error {
            print("Storage couldn't be initialized \(error.localizedDescription)")
            fatalError()
        }
        #if targetEnvironment(simulator)
        print("Database file at \(databasePath.appendingPathComponent("payforme.sqlite").path)")
        #endif
        testLegacy()
        print("Storage service initialized")
    }
    
    func saveProject(project: Project) {
        let storedProject = StoredProject(project: project)
        do {
            try dbQueue.write { db in
                try storedProject.save(db)
            }
        } catch let error {
            print("Couldn't store projects \(error.localizedDescription)")
        }
    }
    
    func saveMembersAndBills(for project: Project) {
        saveBillsForProject(project: project)
        saveMembersForProject(project: project)
    }

    func loadProjects() -> [Project] {
        do {
            return try dbQueue.read { db in
                try StoredProject.fetchAll(db).map { $0.toProject() }
            }
        } catch let error {
            print("Catched \(error.localizedDescription) while loading projects")
            return []
        }
    }
    
    func removeProject(project: Project) {
        let storedProject = StoredProject(project: project)
        do {
            try dbQueue.write { db in
                try storedProject.delete(db)
            }
        } catch let error {
            print("Couldn't remove projects \(error.localizedDescription)")
        }
    }
    
    func loadBillsAndMembers(for currentProject: Project) -> Project {
        do {
            try dbQueue.read { db in
                currentProject.bills = try Bill.fetchAll(db)
                let keyValuePairMembers = try Person.fetchAll(db).map { ($0.id, $0) }
                currentProject.members = Dictionary(uniqueKeysWithValues: keyValuePairMembers)
            }
        } catch let error {
            print("Couldn't load bills and members \(error.localizedDescription)")
        }
        return currentProject
    }
    
    func clearMembersAndBills() {
        do {
            try dbQueue.write { db in
                try Bill.deleteAll(db)
                try Person.deleteAll(db)
            }
        } catch let error {
            print("Couldn't clear bills and members \(error.localizedDescription)")
        }
    }
    
    private func saveBillsForProject(project: Project) {
        let bills = project.bills
        guard !bills.isEmpty else {
            return
        }
        do {
            try dbQueue.write { db in
                //Delete old bills
                try Bill.deleteAll(db)
                try bills.forEach { try $0.save(db) }
            }
        } catch let error {
            print("Couldn't store bills for project \(error.localizedDescription)")
        }
    }
    
    private func saveMembersForProject(project: Project) {
        let members = project.members
        guard !members.isEmpty else {
            return
        }
        do {
            try dbQueue.write { db in
                //Delete old bills
                try Person.deleteAll(db)
                try members.values.forEach { try $0.save(db) }
            }
        } catch let error {
            print("Couldn't store bills for project \(error.localizedDescription)")
        }
    }
    
    private func testLegacy() {
        guard let data = try? Data(contentsOf: legacyFilePath) else {
            return
        }
        print("Found old file URL")
        do {
            let projects = try decoder.decode([OldProject].self, from: data)
            storeProjects(projects: projects.map { $0.toProject() })
            try FileManager.default.removeItem(at: legacyFilePath)
            print("data loaded legacy, will save as new")
        } catch let error {
            print("\(error.localizedDescription)")
        }
    }
    
    private func storeProjects(projects: [StoredProject]) {
        do {
            try dbQueue.write { db in
                try projects.forEach { try $0.save(db) }
            }
        } catch let error {
            print("Couldn't store projects \(error.localizedDescription)")
        }
    }
}

extension StoredProject: FetchableRecord, PersistableRecord {
}

fileprivate class OldProject: Codable, Identifiable {
    let name: String
    let password: String
    let url: URL
    let id: UUID
    let backend: ProjectBackend
    
    var members: [Int : Person]
    var bills: [Bill]
    
    func toProject() -> StoredProject {
        return StoredProject(name: name, password: password, url: url, backend: backend)
    }
}
