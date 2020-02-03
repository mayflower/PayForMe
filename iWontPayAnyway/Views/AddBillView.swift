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
    
    var currentBill: Bill?
    
    var navBarTitle = "Add Bill"
    
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
                    WhoPaidView(members: self.$viewModel.project.members, selectedPayer: self.$selectedPayer).onAppear(perform: {
                        if !self.viewModel.project.members.contains(where: { $0.id == self.selectedPayer }) {
                            self.selectedPayer = self.viewModel.project.members[0].id
                        }
                    })
                    TextField("What was paid?", text: self.$viewModel.topic)
                    TextField("How much?", text: self.$viewModel.amount).keyboardType(.decimalPad)
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
                    ForEach(self.owers.indices, id: \.self) {
                        index in
                        Toggle(isOn: self.$owers[index].isOwing) {
                            Text(self.owers[index].name)
                        }
                    }
                }
                Section {
                    Button(action: self.sendBillToServer) {
                        Text("Send to server")
                    }
                    .disabled(self.$sendBillButtonDisabled.wrappedValue)
                    .onReceive(self.viewModel.validatedInput) {
                        self.sendBillButtonDisabled = !$0
                    }
                }
            }
            .navigationBarTitle(navBarTitle)
            .modifier(DismissingKeyboard())
        }
        .onAppear {
            self.prefillData()
        }
    }
    
    func prefillData() {
        self.initOwers()
        
        guard let bill = currentBill else { return }
        
        self.viewModel.topic = bill.what
        self.viewModel.amount = String(bill.amount)
        
        self.selectedPayer = bill.payer_id
    }
    
    func sendBillToServer() {
        guard let newBill = self.createBill() else {
            print("Could not create bill")
            return
        }
        
        if currentBill != nil {
            CospendNetworkService.instance.updateBill(
                project: self.viewModel.project,
                bill: newBill) { success in
                    if success {
                        CospendNetworkService.instance.loadBills(project: self.viewModel.project, completion: {
                            self.tabBarIndex = tabBarItems.BillList
                            
                        })
                    }
            }
        } else {
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
    }
    
    func createBill() -> Bill? {
        guard let doubleAmount = Double(viewModel.amount) else {
            amount = "Please write a number"
            return nil
        }
        
        let billID: Int
        let date: String
        
        if let currentBill = self.currentBill {
            billID = currentBill.id
            date = currentBill.date
        } else {
            billID = 99
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            date = dateFormatter.string(from: Date())
        }
        
        let actualOwers = owers.filter {$0.isOwing}
            .map {
                Person(id: $0.id, weight: 1, name: $0.name, activated: true)
        }
        
        
        
        return Bill(id: billID, amount: doubleAmount, what: viewModel.topic, date: date, payer_id: selectedPayer, owers: actualOwers, repeat: "n", lastchanged: 0)
        
    }
    
    func initOwers() {
        guard let selectedOwers = currentBill?.owers else {
            self.owers = viewModel.project.members.map{Ower(id: $0.id, name: $0.name, isOwing: false)}
            return
        }
        
        var owers = selectedOwers.map {
            Ower(id: $0.id, name: $0.name, isOwing: true)
        }
        let activeOwerIDs = owers.map {
            $0.id
        }
        let inactiveOwers = viewModel.project.members.map({
            Ower(id: $0.id, name: $0.name, isOwing: false)
        }).filter {
            !activeOwerIDs.contains($0.id)
        }
        
        owers.append(contentsOf: inactiveOwers)
        
        self.owers = owers
    }
}

struct AddBillView_Previews: PreviewProvider {
    static var previews: some View {
        previewProject.members = previewPersons
        previewProject.bills = previewBills
        return AddBillView(tabBarIndex: .constant(tabBarItems.AddBill), viewModel: BillListViewModel(project: previewProject))
    }
}

struct DismissingKeyboard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                let keyWindow = UIApplication.shared.connectedScenes
                    .filter({$0.activationState == .foregroundActive})
                    .map({$0 as? UIWindowScene})
                    .compactMap({$0})
                    .first?.windows
                    .filter({$0.isKeyWindow}).first
                keyWindow?.endEditing(true)
        }
    }
}
