//
//  AddBillView.swift
//  iWontPayAnyway
//
//  Created by Camille Mainz on 13.02.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import SwiftUI

struct AddBillView: View {
    
    @Binding
    var showModal: Bool
    
    @ObservedObject
    var viewModel: BillListViewModel
    
    var body: some View {
        NavigationView {
            BillDetailView(showModal: $showModal, viewModel: viewModel, navBarTitle: "Add Bill", owers: viewModel.currentProject.members.map{Ower(id: $0.id, name: $0.name, isOwing: false)})
        }
    }
}

//struct AddBillView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddBillView()
//    }
//}
