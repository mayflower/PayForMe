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
        VStack {
            Form {
                Section(header: Text("Payer")) {
                    WhoPaidView(members: Array(viewModel.currentProject.members.values), selectedPayer: self.$viewModel.selectedPayer).onAppear {
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
                
            }
            FancyButton(isDisabled: $sendBillButtonDisabled, isLoading: $sendingInProgress, action: self.sendBillToServer, text: showModal ? "Create Bill" : "Update Bill")
                .onReceive(self.viewModel.validatedInput) {
                    self.sendBillButtonDisabled = !$0
            }
        .padding()
        }
        .navigationBarTitle(navBarTitle)
        .onAppear {
            self.hidePlusButton = true
        }
        .onDisappear {
            self.hidePlusButton = false
        }
        .background(Color.PFMBackground)
    }
    
    func sendBillToServer() {
        guard let newBill = self.viewModel.createBill() else {
            print("Could not create bill")
            return
        }
        sendingInProgress = true
        ProjectManager.shared.saveBill(newBill, completion: {
            self.sendingInProgress = false
            ProjectManager.shared.updateCurrentProject()
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

