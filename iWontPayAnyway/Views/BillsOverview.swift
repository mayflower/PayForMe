//
//  BillsOverview.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 22.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import SwiftUI
import Combine

struct BillsOverview: View {
    
    var body: some View {
        VStack {
            BillsList()
        }
    }
}

//struct BillsOverview_Previews: PreviewProvider {
//    static var previews: some View {
//        let project = Project(name: "TestProject", password: "TestPassword", url: "https://testserver.mayflower.de")
//        project.bills = previewBills
//        project.members = previewPersons
//
//        return BillsOverview(viewModel: viewModel).environmentObject(ServerManager())
//    }
//}
