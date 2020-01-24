//
//  BillListViewModel.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 23.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class BillListViewModel: ObservableObject {
    
    let server: Server
    
    @Published
    var project: Project {
        didSet {
            didChange.send(self)
        }
    }
    
    init(server: Server, project: Project) {
        self.server = server
        self.project = project
        CospendNetworkService.instance.updateBills(server: server, project: project
            , completion: {
                bills in
                project.bills = bills
                self.didChange.send(self)
        })
    }
    
    let didChange = PassthroughSubject<BillListViewModel,Never>()
}
