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
    
    @State
    var addingUser = false
    
    @State
    var showConnectionIndicator = false
    
    @State
    var memberName = ""
    
    var body: some View {
        NavigationView {
            mainView
            .navigationBarItems(trailing: !addingUser ? FancyButton(isLoading: .constant(false), add: true, action: showAddUser, text: "") : nil)
            .navigationBarTitle("Members")
            .onAppear {
                ProjectManager.shared.updateCurrentProject()
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    var mainView: some View {
        VStack(alignment: .center) {
            if addingUser {
                AddMemberView(memberName: $memberName, addMemberAction: submitUser, cancelButtonAction: cancelAddUser)
            }
            list
            .addFloatingAddButton()
        }
    }
    
    var list: some View {
        List {
            ForEach(viewModel.balances.sorted(by: { ($0.amount > $1.amount) || (($0.amount == $1.amount) && ($0.person.name < $1.person.name)) })) {
                balance in
                if balance.amount < 0 {
                    NavigationLink(destination: BillDetailView(showModal: .constant(false), viewModel: BillDetailViewModel(currentBill: self.createSettlingBill(balance: balance)))) {
                        BalanceCell(balance: balance)
                    }
                } else {
                    BalanceCell(balance: balance)
                }
            }
        }
    }
    
    func showAddUser() {
        addingUser = true
    }
    
    func submitUser() {
        ProjectManager.shared.addMember(memberName) {
            self.addingUser = false
            self.memberName = ""
            ProjectManager.shared.updateCurrentProject()
        }
    }
    
    func cancelAddUser() {
        self.memberName = ""
        self.addingUser = false
    }
    
    func createSettlingBill(balance: Balance) -> Bill {
        let ower = viewModel.balances.sorted(by: {$0.amount > $1.amount})[0]
        let payer = balance.person
        let topic = "Settling balance for \(balance.person.name)"
        let amount = ower.amount.magnitude < balance.amount.magnitude ? ower.amount : balance.amount.magnitude
        return Bill(id: 99, amount: amount, what: topic, date: Date(), payer_id: payer.id, owers: [ower.person], repeat: "n")
    }
}


struct BalanceList_Previews: PreviewProvider {
    static var previews: some View {
        let vm = BalanceViewModel()
        vm.currentProject = previewProject
        vm.setBalances()
        return BalanceList(viewModel: vm, addingUser: true)
    }
}

struct BalanceCell: View {
    @State
    var balance: Balance
    
    var body: some View {
        HStack {
            PersonText(person: balance.person)
            Spacer()
            Text(" \(String(format:"%.2f",balance.amount))")
                .font(.headline)
                .foregroundColor( balance.amount >= 0 ? Color.primary : Color.red)
        }.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
    }
}
