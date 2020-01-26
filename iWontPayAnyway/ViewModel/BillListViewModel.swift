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
    var server: Server
    
    @Published
    var project: Project {
        didSet {
            didChange.send(self)
        }
    }
    
    var cancellable: AnyCancellable?
    
    init(server: Server, project: Project) {
        self.server = server
        self.project = project
        
        let url = CospendNetworkService.instance.buildURL(server, project, "bills")!
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .compactMap{
                data, response -> Data? in
                guard let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 200 else { print("Network error"); return nil }
                return data
        }
        .decode(type: [Bill].self, decoder: JSONDecoder())
        .replaceError(with: [])
        .sink{
            bills in
            self.project.bills = bills
            self.didChange.send(self)
        }
    }
    
    let didChange = PassthroughSubject<BillListViewModel,Never>()
}
