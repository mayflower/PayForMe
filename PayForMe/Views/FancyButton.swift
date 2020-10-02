//
//  FancyBotton.swift
//  PayForMe
//
//  Created by Camille Mainz on 24.02.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import SwiftUI

struct FancyButton: View {
    
    @Environment(\.isEnabled) private var isEnabled: Bool
    
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
                Text(LocalizedStringKey(text))
            }
        }
        .fancyStyle(active: self.isEnabled)
        .disabled(!isEnabled)
    }
}

struct FancyBotton_Previews: PreviewProvider {
    static var previews: some View {
        FancyButton(isLoading: .constant(false), add: false, action: ({ return }), text: "Add Project").environment(\.locale, .init(identifier: "de"))
    }
}
