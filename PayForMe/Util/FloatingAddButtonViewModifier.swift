//
//  FloatingAddButtonViewModifier.swift
//  PayForMe
//
//  Created by Max Tharr on 03.10.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import SwiftUI

struct FloatingAddButtonViewModifier: ViewModifier {
    @State private var sheetToggle = false
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $sheetToggle) {
                AddBillView(showModal: $sheetToggle)
            }
            .overlay( FloatingAddButtonView(sheetToggle: $sheetToggle).padding(32), alignment: .bottom)
    }
}

private struct FloatingAddButtonView: View {
    @Binding var sheetToggle: Bool
    
    var body: some View {
            Button(action: {
                sheetToggle.toggle()
            }) {
                Image(systemName: "plus.circle")
                    .resizable()
                    .frame(width: 48, height: 48)
                    .foregroundColor(Color.secondary)
                    .shadow(radius: 10)
            }
    }
}

struct FloatingAddButtonViewModifier_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello World").modifier(FloatingAddButtonViewModifier())
    }
}
