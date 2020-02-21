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

struct BillDetailView: View {
    
    @Environment(\.presentationMode)
    var presentationMode: Binding<PresentationMode>
    
    @Binding
    var showModal: Bool
    
    @Binding
    var hidePlusButton: Bool
    
    @ObservedObject
    var viewModel: BillListViewModel
    
    var currentBill: Bill?
    
    var navBarTitle = "Add Bill"
    var sendButtonTitle = "Create Bill"
    
    @State
    var selectedPayer = 1
    
    @State
    var owers: [Ower] = []
    
    @State
    var noneAllToggle = 1
    
    @State
    var sendBillButtonDisabled = true
    
    @State
    var sendingInProgress = false
    
    var body: some View {
            ZStack {
                Form {
                    Section(header: Text("Payer")) {
                        WhoPaidView(members: viewModel.currentProject.members.map {$0.value}, selectedPayer: self.$selectedPayer).onAppear {
                            if self.viewModel.currentProject.members[self.selectedPayer] == nil {
                                guard let id = self.viewModel.currentProject.members.first?.key else { return }
                                self.selectedPayer = id
                            }
                        }
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
                                PersonText(person: self.viewModel.currentProject.members[self.owers[index].id]!)
                            }
                        }
                    }
                    Section {
                        Button(action: self.sendBillToServer) {
                            Text(sendButtonTitle)
                        }
                        .disabled(self.$sendBillButtonDisabled.wrappedValue)
                        .onReceive(self.viewModel.validatedInput) {
                            self.sendBillButtonDisabled = !$0
                        }
                    }
                }
                .navigationBarTitle(navBarTitle)
                if sendingInProgress {
                    Image(systemName: "arrow.2.circlepath.circle")
                        .resizable()
                        .frame(width: 256, height: 256)
                }
            }
        .onAppear {
            self.hidePlusButton = true
            self.prefillData()
        }
            .onDisappear {
                self.hidePlusButton = false
        }
    }
    
    func prefillData() {
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
        sendingInProgress = true
        ProjectManager.shared.saveBill(newBill, completion: {
            self.sendingInProgress = false
            self.showModal.toggle()
            DispatchQueue.main.async {
                self.presentationMode.wrappedValue.dismiss()
            }
        })
    }
    
    func createBill() -> Bill? {
        guard let doubleAmount = Double(viewModel.amount) else {
            return nil
        }
        
        let billID: Int
        let date: Date
        
        if let currentBill = self.currentBill {
            billID = currentBill.id
            date = currentBill.date
        } else {
            billID = 99
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            date = Date()
        }
        
        let actualOwers = owers.filter {$0.isOwing}
            .map {
                Person(id: $0.id, weight: 1, name: $0.name, activated: true)
        }
        
        
        
        return Bill(id: billID, amount: doubleAmount, what: viewModel.topic, date: date, payer_id: selectedPayer, owers: actualOwers, repeat: "n", lastchanged: 0)
        
    }
}

struct BillDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = BillListViewModel()
        vm.currentProject = previewProject
        return BillDetailView(showModal: .constant(true), hidePlusButton: .constant(true), viewModel: vm)
    }
}

