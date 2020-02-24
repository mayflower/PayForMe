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
    
    var body: some View {
        NavigationView {
            ProjectDetailView(hidePlusButton: self.$hidePlusButton)
        }
    }
}

struct AddProjectView_Previews: PreviewProvider {
    static var previews: some View {
        AddProjectView(hidePlusButton: .constant(false))
    }
}
