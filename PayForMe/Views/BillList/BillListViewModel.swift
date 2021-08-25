//
//  BillListViewModel.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 23.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import Foundation
import Combine

class BillListViewModel: ObservableObject {
    
    var manager = ProjectManager.shared
    var cancellable: Cancellable?
    
    @Published
    var currentProject: Project
    
    @Published
    var sortBy = SortedBy.expenseDate
    
    @Published
    var sorter = ""
    
    @Published
    var sortedBills = [Bill]()
    
    init() {
        self.currentProject = manager.currentProject
        self.cancellable = currentProjectChanged
        $sortBy
            .map {
                $0.sort(bills: self.currentProject.bills)
            }
            .assign(to: &$sortedBills)
    }
    
    var currentProjectChanged: AnyCancellable {
        manager.$currentProject
            .assign(to: \.currentProject, on: self)
    }
    
    enum SortedBy: String {
        case expenseDate
        case changedDate
        
        func sort(bills: [Bill]) -> [Bill] {
            switch(self) {
            case .expenseDate:
                return bills.sorted { a, b in
                    a.date > b.date
                }
            case .changedDate:
                return bills.sorted { a, b in
                    a.lastchanged ?? 0 > b.lastchanged ?? 0
                }
            }
        }
    }
}
