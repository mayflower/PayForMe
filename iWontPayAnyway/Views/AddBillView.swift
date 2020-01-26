//
//  AddBillView.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 23.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import SwiftUI
import Foundation

struct AddBillView: View {
    @Binding
    var addBillToggle: Bool
    
    @Binding
    var server: Server
    
    @Binding
    var project: Project
    
    @State
    var selectedPayer = 1
    
    @State
    var what = ""
    
    @State
    var amount = ""
    
    @State
    var owers: [Ower] = []
    
    @State
    var noneAllToggle = 1
    
    
    var body: some View {
        Form {
            Text("New bill")
            WhoPaidView(members: $project.members, selectedPayer: $selectedPayer).onAppear(perform: {
                self.selectedPayer = self.project.members[0].id
            })
            TextField("What was paid?", text: $what)
            TextField("How much?", text: $amount).keyboardType(.numberPad)
            Section {
                Text("Owers:")
                HStack {
                    Button(action: {
                        print("none")
                        self.owers = self.owers.map{Ower(id: $0.id, name: $0.name, isOwing: false)}
                    }) {
                        Text("None")
                    }.buttonStyle(BorderlessButtonStyle())
                    Spacer()
                    Button(action: {
                        print("all")

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
            }
        }
    }
    
    func sendBillToServer() {
        guard let newBill = self.createBill() else {
            print("Could not create bill")
            return
        }
        CospendNetworkService.instance.postNewBill(
            server: self.server,
            project: self.project,
            bill: newBill,
            completion: {
                CospendNetworkService.instance.updateBills(server: self.server, project: self.project, completion: {self.project.bills = $0})
                self.addBillToggle = !$0
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
        
        return Bill(id: 99, amount: doubleAmount, what: what, date: date, payer_id: selectedPayer, owers: actualOwers, repeat: "n", lastchanged: 0)
    }
    
    func initOwers() {
        owers = project.members.map{Ower(id: $0.id, name: $0.name, isOwing: false)}
    }
}

struct AddBillView_Previews: PreviewProvider {
    static var previews: some View {
        previewProject.members = previewPersons
        let project = Project(name: "test1", password: "test23")
        project.bills = previewBills
        let server = Server(name: "test", url: "https://testserver.mayflower.de", projects: [project])
        return AddBillView(addBillToggle: .constant(false), server: .constant(server), project: .constant(previewProject))
    }
}
