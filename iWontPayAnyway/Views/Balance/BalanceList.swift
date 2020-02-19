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
        NavigationView {
            ScrollView {
                VStack() {
                    ForEach(viewModel.balances.sorted(by: { $0.amount > $1.amount })) {
                        balance in
                        VStack {
                            BalanceCell(balance: balance)
                            Divider()
                        }
                    }
                    Spacer()
                }
            }
            .navigationBarTitle("Balance")
        }
        .onAppear {
            ProjectManager.shared.updateCurrentProject()
        }
    }
}

struct BalanceList_Previews: PreviewProvider {
    static var previews: some View {
        return BalanceList(viewModel: BalanceViewModel())
    }
}

struct BalanceCell: View {
    @State
    var balance: Balance
    
    var body: some View {
        HStack {
                ColorIndicator(color: balance.color, name: balance.name)
            Spacer()
            Text(" \(String(format:"%.2f",balance.amount)) €")
                .font(.headline)
                .foregroundColor( balance.amount > 0 ? Color.primary : Color.red)
        }.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
    }
}
