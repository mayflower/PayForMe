//
//  ColorIndicator.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 13.02.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import SwiftUI

struct ColorIndicator: View {
    @State
    var color: Color
    
    @State
    var name: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(color).frame(width: 200, height: 25, alignment: .leading)
            Text(name).foregroundColor(Color.primary).multilineTextAlignment(.leading).font(.headline).padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        }
    }
}

struct ColorIndicator_Previews: PreviewProvider {
    static var previews: some View {
        ColorIndicator(color: Color.red, name: "Torsten")
    }
}
