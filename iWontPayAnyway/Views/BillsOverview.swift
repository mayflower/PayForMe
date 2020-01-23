//
//  BillsOverview.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 22.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import SwiftUI

struct BillsOverview: View {
    
    @State
    var bills: [Bill]
    
    @State
    private var addBills = false
    
    var body: some View {
        VStack {
            Button(action: {
                self.addBills.toggle()
            }) {
                Text("Add Bill")
            }
            if (addBills) {
                AddBillView()
            }
            List(bills) {
                BillCell(bill: $0)
            }
        }
    }
}

struct BillsOverview_Previews: PreviewProvider {
    static var previews: some View {
        BillsOverview(bills: previewBills)
    }
}
