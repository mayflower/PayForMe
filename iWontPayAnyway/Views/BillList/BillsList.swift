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
                    ForEach(viewModel.currentProject.bills.sorted(by: {
                        $0.date > $1.date
                    })) { bill in
                        NavigationLink(destination: AddBillView(tabBarIndex: self.$tabBarIndex, viewModel: self.viewModel, currentBill: bill, navBarTitle: "Edit Bill")) {
                            BillCell(viewModel: self.viewModel, bill: bill)
                        }
                    }
                }
            }
            .navigationBarTitle("Bills")
        }
    }
    
}
