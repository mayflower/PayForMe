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
        VStack() {
            ForEach(viewModel.balances) {
                balance in
                HStack {
                    Text("\(balance.name)")
                    Spacer()
                    Text(" \(String(format:"%.2f",balance.amount)) €").fontWeight(.bold)
                }.padding().background(self.backGroundColor(
                    balance))
            }
            Spacer()
        }
    }
    
    func backGroundColor(_ balance: Balance) -> LinearGradient {
        return LinearGradient(gradient: Gradient(colors: [Color(balance.color),Color.white]), startPoint: .leading, endPoint: .trailing)
    }
}

struct BalanceList_Previews: PreviewProvider {
    static var previews: some View {
        previewProject.bills = previewBills
        previewProject.members = previewPersons
        return BalanceList(viewModel: BalanceViewModel(project: previewProject))
    }
}
