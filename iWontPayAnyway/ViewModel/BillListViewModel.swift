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
    
    @Published
    var project: Project {
        didSet {
            didChange.send(self)
        }
    }
    
    var cancellable: AnyCancellable?
    
    init(project: Project) {
        self.project = project
        
        CospendNetworkService.instance.loadBills(project: project, completion: {
            self.didChange.send(self)
        })
    }
    
    let didChange = PassthroughSubject<BillListViewModel,Never>()
}
