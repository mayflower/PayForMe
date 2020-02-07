//
//  AddServerModel.swift
//  iWontPayAnyway
//
//  Created by Camille Mainz on 05.02.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import Foundation
import UIKit
import Combine

class AddServerModel: ObservableObject {
    
    @Published
    var serverAddress = ""
    
    @Published
    var projectName = ""
    
    @Published
    var projectPassword = ""
    
    var validatedInput: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest3($serverAddress, $projectName, $projectPassword)
            .map { address, name, password in
                return address.isValidURL && !name.isEmpty && !password.isEmpty
            }
            .eraseToAnyPublisher()
    }
    
}
