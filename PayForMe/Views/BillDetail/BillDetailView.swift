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
    var viewModel: BillDetailViewModel
    
    var navBarTitle = "Add Bill"
    var sendButtonTitle = "Create Bill"
        
    @State
    var noneAllToggle = 1
    
    @State
    var sendBillButtonDisabled = true
    
    @State
    var sendingInProgress = false
    
    var body: some View {
            ZStack {
                VStack {
                    Form {
                        Section(header: Text("Payer")) {
                            WhoPaidView(members: viewModel.currentProject.members.map {$0.value}, selectedPayer: self.$viewModel.selectedPayer).onAppear {
                                if self.viewModel.currentProject.members[self.viewModel.selectedPayer] == nil {
                                    guard let id = self.viewModel.currentProject.members.first?.key else { return }
                                    self.viewModel.selectedPayer = id
                                }
                            }
                            TextField("What was paid?", text: self.$viewModel.topic)
                            TextField("How much?", text: self.$viewModel.amount).keyboardType(.decimalPad)
                        }
                        Section(header: Text("Owers")) {
                            PotentialOwersView(vm: viewModel.povm)
                        }
                            
                    }.scaledToFit()
                    FancyButton(isDisabled: $sendBillButtonDisabled, action: self.sendBillToServer, text: "Create Bill")
                        .onReceive(self.viewModel.validatedInput) {
                            self.sendBillButtonDisabled = !$0
                    }
                    Spacer()
                }
                .navigationBarTitle(navBarTitle)
                if sendingInProgress {
                    CommunicationIndicator()
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
        let bill = viewModel.currentBill
        
        self.viewModel.topic = bill.what
        self.viewModel.amount = String(bill.amount)
        
        self.viewModel.selectedPayer = bill.payer_id
    }
    
    func sendBillToServer() {
        guard let newBill = self.viewModel.createBill() else {
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
}

struct BillDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = BillDetailViewModel(currentBill: previewBills[0])
        vm.currentProject = previewProject
        return BillDetailView(showModal: .constant(true), hidePlusButton: .constant(true), viewModel: vm)
    }
}

