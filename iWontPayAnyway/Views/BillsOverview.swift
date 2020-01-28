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
    
    @EnvironmentObject
    var serverManager: ServerManager
    
    @ObservedObject
    var viewModel: BillListViewModel
    
    @State
    private var billsLoaded = true
    
    var body: some View {
        VStack {
            if billsLoaded {
                BillsList(viewModel: viewModel)
                
            } else {
                Image(systemName: "arrow.2.circlepath").resizable().frame(width: 50, height: 50)
                Text("Loading Bills, please wait")
            }
        }
    }
}

struct BillsOverview_Previews: PreviewProvider {
    static var previews: some View {
        let project = Project(name: "TestProject", password: "TestPassword", url: "https://testserver.mayflower.de")
        project.bills = previewBills
        project.members = previewPersons
        let viewModel = BillListViewModel(project: project)
        return BillsOverview(viewModel: viewModel).environmentObject(ServerManager())
    }
}
