//
//  Util.swift
//  iWontPayAnyway
//
//  Created by Camille Mainz on 28.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import Foundation

extension Collection {
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
