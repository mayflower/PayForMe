//
//  AddProjectView.swift
//  iWontPayAnyway
//
//  Created by Camille Mainz on 14.02.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import SwiftUI

struct AddProjectView: View {
    
    @Binding
    var hidePlusButton: Bool
    
    @State var isQRScanning = false
    
    var body: some View {
        NavigationView {
            if isQRScanning {
                AddProjectQRView()
            } else {
                ProjectDetailView(hidePlusButton: self.$hidePlusButton)
            }
        }
    }
}

struct AddProjectView_Previews: PreviewProvider {
    static var previews: some View {
        AddProjectView(hidePlusButton: .constant(false)).environment(\.locale, .init(identifier: "de"))
    }
}
