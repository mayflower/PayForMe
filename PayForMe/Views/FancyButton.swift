//
//  FancyBotton.swift
//  PayForMe
//
//  Created by Camille Mainz on 24.02.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import SwiftUI

struct FancyButton: View {
    
    @Binding
    var isDisabled: Bool
    
    var action: () -> Void
    var text: String
    
    var body: some View {
        Button(action: action) {
            Text(text)
        }
        .padding(10)
        .background(self.isDisabled ? Color.gray : Color.blue)
            
        .foregroundColor(.white)
            
        .cornerRadius(10)
        .disabled(isDisabled)
    }
}

struct FancyBotton_Previews: PreviewProvider {
    static var previews: some View {
        FancyButton(isDisabled: .constant(false), action: ({ return }), text: "Add Project")
    }
}
