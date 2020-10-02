//
//  Combine.swift
//  PayForMe
//
//  Created by Max Tharr on 02.10.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import Combine
import Foundation

extension Publisher {
    var asUIPublisher: some Publisher {
        self.receive(on: RunLoop.main)
    }
}
