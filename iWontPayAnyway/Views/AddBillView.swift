//
//  AddBillView.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 23.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import SwiftUI

struct AddBillView: View {
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
            WhoPaidView(members: $project.members, selectedPayer: $selectedPayer)
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
        }
    }
    
    func initOwers() {
        owers = project.members.map{Ower(id: $0.id, name: $0.name, isOwing: false)}
    }
}

struct AddBillView_Previews: PreviewProvider {
    static var previews: some View {
        previewProject.members = previewPersons
        return AddBillView(project: .constant(previewProject))
    }
}
