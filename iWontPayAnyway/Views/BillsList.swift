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
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.project.bills.sorted(by: {
                    $0.lastchanged > $1.lastchanged
                })) {
                    BillCell(project: self.$viewModel.project,bill: $0)
                }
            }
        }
    }
}
