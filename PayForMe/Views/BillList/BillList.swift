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
    
    @State
    var deleteAlert = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.currentProject.bills) { bill in
                    NavigationLink(destination:
                        BillDetailView(showModal: .constant(false),
                                       viewModel: BillDetailViewModel(currentBill: bill),
                                       navBarTitle: "Edit Bill",
                                       sendButtonTitle: "Update Bill")) {
                                        BillCell(viewModel: self.viewModel, bill: bill)
                    }
                }
                .onDelete(perform: {
                    offset in
                    self.deleteAlert.toggle()
                })
            }
            .id(viewModel.currentProject.bills)
            .navigationBarTitle("Bills")
            .addFloatingAddButton()
            .alert(isPresented: $deleteAlert) {
                Alert(title: Text("Delete Bill"), message: Text("Do you really want to erase the bill from the server?"), primaryButton: .destructive(Text("Sure")), secondaryButton: .cancel())
            }
        }
        .onAppear {
            ProjectManager.shared.updateCurrentProject()
        }
    }
    
    func deleteBill(at offsets: IndexSet) {
        for offset in offsets {
            guard let bill = viewModel.currentProject.bills[safe: offset] else {
                return
            }
            ProjectManager.shared.deleteBill(bill, completion: {
                ProjectManager.shared.updateCurrentProject()
            })
        }
    }
    
}

struct BillList_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = BillListViewModel()
        previewProject.bills = previewBills
        previewProject.members = previewPersons
        viewModel.currentProject = previewProject
        return BillList(viewModel: viewModel, tabBarIndex: .BillList)
    }
}
