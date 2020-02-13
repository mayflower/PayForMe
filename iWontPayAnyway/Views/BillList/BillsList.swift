//
//  BillsList.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 26.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import SwiftUI

struct BillsList: View {
    
    @ObservedObject
    var viewModel: BillListViewModel
    
    @State
    var tabBarIndex = tabBarItems.AddBill
    
    var body: some View {
        
        ScrollView {
            VStack {
                ForEach(viewModel.currentProject.bills.sorted(by: {
                    $0.lastchanged > $1.lastchanged
                })) { bill in
                    
                    BillCell(viewModel: self.viewModel, bill: bill)
                }
            }
        }
        .onAppear {
            ProjectManager.shared.updateCurrentProject()
        }
    }
    
}
