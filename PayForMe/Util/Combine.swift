//
//  Combine.swift
//  PayForMe
//
//  Created by Max Tharr on 02.10.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import Combine
import Foundation

extension Publisher where Failure == Never {
    var asUIPublisher: AnyPublisher<Output,Never>  {
        self.receive(on: RunLoop.main).eraseToAnyPublisher()
    }
}
