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
        NavigationView {
            ScrollView {
                VStack {
                    ForEach(viewModel.project.bills.sorted(by: {
                        $0.lastchanged > $1.lastchanged
                    })) { bill in
                        NavigationLink(destination: AddBillView(tabBarIndex: self.$tabBarIndex, currentBill: bill, navBarTitle: "Edit Bill", viewModel: self.viewModel)) {
                            BillCell(project: self.$viewModel.project, bill: bill)
                        }
                    }
                }
            }
            .navigationBarTitle("Bills")
        }
    }
    
}
