//
//  Ower.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 26.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import Foundation

struct Ower: Hashable, Identifiable {
    let id: Int
    let name: String
    var isOwing: Bool
}
