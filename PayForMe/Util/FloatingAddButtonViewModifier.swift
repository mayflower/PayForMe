//
//  FloatingAddButtonViewModifier.swift
//  PayForMe
//
//  Created by Max Tharr on 03.10.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import SwiftUI

struct FloatingAddButtonViewModifier: ViewModifier {
    @State var sheetToggle = false
    
    func body(content: Content) -> some View {
        ZStack {
            content
            VStack {
                Spacer()
                Button(action: {
                    sheetToggle.toggle()
                }) {
                    Image(systemName: "plus.circle")
                        .resizable()
                        .frame(width: 64, height: 64)
                        .foregroundColor(Color.secondary)
                        .shadow(radius: 10)
                }
            }.padding(EdgeInsets(top: 0, leading: 32, bottom: 64, trailing: 32))
        }
        .sheet(isPresented: $sheetToggle) {
            AddBillView(showModal: $sheetToggle)
        }
    }
}

struct FloatingAddButtonViewModifier_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello World").modifier(FloatingAddButtonViewModifier())
    }
}
