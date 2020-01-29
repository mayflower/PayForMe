//
//  AddBillView.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 23.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import SwiftUI
import Foundation
import Combine

struct AddBillView: View {
    @Binding
    var tabBarIndex: tabBarItems
    
    @ObservedObject
    var viewModel: BillListViewModel
    
    @State
    var selectedPayer = 1
    
    @State
    var topic = ""
    
    @State
    var amount = ""
    
    @State
    var owers: [Ower] = []
    
    @State
    var noneAllToggle = 1
    
    @State
    var sendBillButtonDisabled = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Payer")) {
                    WhoPaidView(members: $viewModel.project.members, selectedPayer: $selectedPayer).onAppear(perform: {
                        if !self.viewModel.project.members.contains(where: { $0.id == self.selectedPayer }) {
                            self.selectedPayer = self.viewModel.project.members[0].id
                        }
                    })
                    TextField("What was paid?", text: $viewModel.topic)
                    TextField("How much?", text: $viewModel.amount).keyboardType(.numberPad)
                }
                Section(header: Text("Owers")) {
                    HStack {
                        Button(action: {
                            self.owers = self.owers.map{Ower(id: $0.id, name: $0.name, isOwing: false)}
                        }) {
                            Text("None")
                        }.buttonStyle(BorderlessButtonStyle())
                        Spacer()
                        Button(action: {
                            self.owers = self.owers.map{Ower(id: $0.id, name: $0.name, isOwing: true)}
                        }) {
                            Text("All")
                        }.buttonStyle(BorderlessButtonStyle())
                    }.padding(16)
                    ForEach(owers.indices, id: \.self) {
                        index in
                        Toggle(isOn: self.$owers[index].isOwing) {
                            Text(self.owers[index].name)
                        }
                    }
                }.onAppear(perform: initOwers)
                Section {
                    Button(action: sendBillToServer) {
                        Text("Send to server")
                    }
                    .disabled($sendBillButtonDisabled.wrappedValue)
                    .onReceive(self.viewModel.validatedInput) {
                        self.sendBillButtonDisabled = !$0
                    }
                }
            }
        }
    }
    
    func sendBillToServer() {
        guard let newBill = self.createBill() else {
            print("Could not create bill")
            return
        }
        CospendNetworkService.instance.postBill(
            project: self.viewModel.project,
            bill: newBill,
            completion: {
                success in
                if success {
                    CospendNetworkService.instance.loadBills(project: self.viewModel.project, completion: {
                        self.tabBarIndex = tabBarItems.BillList
                        
                    })
                }
        })
    }
    
    func createBill() -> Bill? {
        guard let doubleAmount = Double(amount) else {
            amount = "Please write a number"
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let date = dateFormatter.string(from: Date())
        let actualOwers = owers.filter {$0.isOwing}
            .map {
                Person(id: $0.id, weight: 1, name: $0.name, activated: true)
        }
        
        return Bill(id: 99, amount: doubleAmount, what: topic, date: date, payer_id: selectedPayer, owers: actualOwers, repeat: "n", lastchanged: 0)
    }
    
    func initOwers() {
        owers = viewModel.project.members.map{Ower(id: $0.id, name: $0.name, isOwing: false)}
    }
}

struct AddBillView_Previews: PreviewProvider {
    static var previews: some View {
        previewProject.members = previewPersons
        previewProject.bills = previewBills
        return AddBillView(tabBarIndex: .constant(tabBarItems.AddBill), viewModel: BillListViewModel(project: previewProject))
    }
}
