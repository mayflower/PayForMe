//
//  BalanceList.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 29.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import SwiftUI

struct BalanceList: View {
    
    @ObservedObject
    var viewModel: BalanceViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.balances) {
                balance in
                Text("\(balance.name) paid \(String(format:"%.2f",balance.amount)) €")
            }
        }
    }
}

struct BalanceList_Previews: PreviewProvider {
    static var previews: some View {
        previewProject.bills = previewBills
        previewProject.members = previewPersons
        return BalanceList(viewModel: BalanceViewModel(project: previewProject))
    }
}
