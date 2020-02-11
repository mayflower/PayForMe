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

extension String {
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            return (match.range.length == self.utf16.count) && (self.contains("https://") || self.contains("http://"))
        }
        return false
    }
}

extension DateFormatter {
    static let cospend: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        return formatter
    }()
}
