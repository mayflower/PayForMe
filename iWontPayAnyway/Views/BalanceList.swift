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
    
    @ObservedObject
    var manager = DataManager.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack() {
                    ForEach(viewModel.balances.sorted(by: { $0.amount > $1.amount })) {
                        balance in
                        VStack {
                            HStack {
                                Circle().foregroundColor(Color(balance.color)).frame(width: 25, height: 25)
                                Spacer()
                                Text("\(balance.name)").font(.headline)
                                Text(" \(String(format:"%.2f",balance.amount)) €")
                            }.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                            Divider()
                        }
                    }
                    Spacer()
                }
            }
            .navigationBarTitle("Balance")
        }
        .onAppear {
            self.viewModel.project = self.manager.currentProject
            self.viewModel.setBalances()
        }
    }
}

struct BalanceList_Previews: PreviewProvider {
    static var previews: some View {
        return BalanceList(viewModel: BalanceViewModel(project: previewProject))
    }
}
