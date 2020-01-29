//
//  Util.swift
//  iWontPayAnyway
//
//  Created by Camille Mainz on 28.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import Foundation
import SwiftUI

extension Collection {
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Color {
    init(_ pc: PersonColor) {
        self.init(red: Double(pc.r)/255, green: Double(pc.g)/255, blue: Double(pc.b)/255, opacity: 1)
    }
}
