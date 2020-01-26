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
    
    @ObservedObject
    var viewModel: BillListViewModel
    
    @State
    private var addBills = false
    
    @State
    private var billsLoaded = true
    
    var body: some View {
        VStack {
            Button(action: {
                withAnimation{ self.addBills.toggle()}
            }) {
                Text("Add Bill")
            }
            if (addBills) {
                AddBillView(project: .constant(viewModel.project))
            }
            if billsLoaded {
                List(viewModel.project.bills) {
                    BillCell(project: .constant(self.viewModel.project),bill: $0)
                }
            } else {
                Image(systemName: "arrow.2.circlepath").resizable().frame(width: 50, height: 50)
                Text("Loading Bills, please wait")
            }
        }
    }
}

struct BillsOverview_Previews: PreviewProvider {
    static var previews: some View {
        let project = Project(name: "TestProject", password: "TestPassword")
        project.bills = previewBills
        let server = Server(name: "test", url: "https://testserver.mayflower.de", projects: [project])
        let viewModel = BillListViewModel(server: server, project: project)
        return BillsOverview(viewModel: viewModel)
    }
}
