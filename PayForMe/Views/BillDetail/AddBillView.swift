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
    
    var body: some View {
        NavigationView {
            BillDetailView(showModal: $showModal, hidePlusButton: .constant(false), viewModel: BillDetailViewModel(currentBill: Bill.newBill()), navBarTitle: "Add Bill")
        }
    }
}

//struct AddBillView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddBillView()
//    }
//}
