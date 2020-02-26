//
//  BillsList.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 26.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import SwiftUI

struct BillList: View {
    
    @ObservedObject
    var viewModel: BillListViewModel
    
    @State
    var tabBarIndex = tabBarItems.AddBill
    
    @Binding
    var hidePlusButton: Bool
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.currentProject.bills.sorted(by: {
                    if let l1 = $0.lastchanged,
                        let l2 = $1.lastchanged {
                        return l1 > l2
                    }
                    return $0.date > $1.date
                })) { bill in
                    NavigationLink(destination:
                        BillDetailView(showModal: .constant(false),
                                       hidePlusButton: self.$hidePlusButton,
                                       viewModel: BillDetailViewModel(currentBill: bill),
                                       navBarTitle: "Edit Bill",
                                       sendButtonTitle: "Update Bill")) {
                                        BillCell(viewModel: self.viewModel, bill: bill)
                    }
                }
                .onDelete(perform: deleteBill)
            }
            .id(viewModel.currentProject.bills)
            .navigationBarTitle("Bills")
        }
        .onAppear {
            ProjectManager.shared.updateCurrentProject()
        }
    }
    
    func deleteBill(at offsets: IndexSet) {
        for offset in offsets {
            guard let bill = viewModel.currentProject.bills.sorted(by: {
                if let l1 = $0.lastchanged,
                    let l2 = $1.lastchanged {
                    return l1 > l2
                }
                return $0.date > $1.date
            })[safe: offset] else {
                return
            }
            ProjectManager.shared.deleteBill(bill)
        }
    }
    
}

struct BillList_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = BillListViewModel()
        previewProject.bills = previewBills
        previewProject.members = previewPersons
        viewModel.currentProject = previewProject
        return BillList(viewModel: viewModel, tabBarIndex: .BillList, hidePlusButton: .constant(false))
    }
}
