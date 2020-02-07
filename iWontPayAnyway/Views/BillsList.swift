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
    var manager = DataManager.shared
    
    @State
    var tabBarIndex = tabBarItems.AddBill
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ForEach(manager.currentBills.sorted(by: {
                        $0.lastchanged > $1.lastchanged
                    })) { bill in
                        NavigationLink(destination: AddBillView(tabBarIndex: self.$tabBarIndex, viewModel: BillListViewModel(), currentBill: bill, navBarTitle: "Edit Bill")) {
                            BillCell(bill: bill)
                        }
                    }
                }
            }
            .navigationBarTitle("Bills")
        }
    }
    
}
