//
//  Views+Extensions.swift
//  PayForMe
//
//  Created by Max Tharr on 03.10.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import Foundation
import SwiftUI

extension View {
    func fancyStyle(active: Bool = true) -> some View {
        self
            .padding(10)
            .background(active ? Color.blue : Color.gray)
            .foregroundColor(.white)
            
            .cornerRadius(10)
            .shadow(color: (active ? Color.blue : Color.gray).opacity(0.5), radius: 4, x: 2, y: 2)
    }
    
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
    
    func addFloatingAddButton() -> some View {
        self.modifier(FloatingAddButtonViewModifier())
    }
}
