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
    
    init() {
        self.currentProject = manager.currentProject
        self.cancellable = currentProjectChanged
    }
    
    var currentProjectChanged: AnyCancellable {
        manager.$currentProject
            .assign(to: \.currentProject, on: self)
    }
}
