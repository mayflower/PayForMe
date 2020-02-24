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
            BillDetailView(showModal: $showModal, hidePlusButton: .constant(false), viewModel: viewModel, navBarTitle: "Add Bill", owers: viewModel.currentProject.members.map{Ower(id: $0.key, name: $0.value.name, isOwing: false)})
        }
    }
}

//struct AddBillView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddBillView()
//    }
//}
