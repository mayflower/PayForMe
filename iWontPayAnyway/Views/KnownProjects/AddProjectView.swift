//
//  AddProjectView.swift
//  iWontPayAnyway
//
//  Created by Camille Mainz on 14.02.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import SwiftUI

struct AddProjectView: View {
    
    @ObservedObject
    var addProjectModel: AddProjectModel
    
    var body: some View {
        NavigationView {
            ProjectDetailView(addProjectModel: addProjectModel)
        }
    }
}

//struct AddProjectView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddProjectView()
//    }
//}
