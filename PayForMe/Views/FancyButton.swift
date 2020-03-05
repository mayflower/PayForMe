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
    
    @Binding
    var isLoading: Bool
    
    var add: Bool
    
    var action: () -> Void
    var text: String
    
    var body: some View {
        Button(action: action) {
            if isLoading {
                HStack {
                    Text("Finding Server")
                    
                    LoadingRings()
                        .scaleEffect(0.2)
                        .frame(width: 25, height: 25)
                }
            } else if add {
                Image(systemName: "plus")
            } else {
                Text(text)
            }
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
        FancyButton(isDisabled: .constant(false), isLoading: .constant(false), add: false, action: ({ return }), text: "Add Project")
    }
}
