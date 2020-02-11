//
//  OnboardingView.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 21.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import SwiftUI
import Combine

struct OnboardingView: View {
    
    @Environment(\.presentationMode)
    var presentationMode: Binding<PresentationMode>
    
    @ObservedObject
    var addServerModel: AddServerModel
    
    @State
    var addServerButtonDisabled = true
    
    var body: some View {
            Form {
                Text("Add new project").font(.title)
                Section(header: Text("Server Address")) {
                    TextField("https://mynextcloud.org", text: self.$addServerModel.serverAddress).autocapitalization(.none).keyboardType(.URL)
                }
                Section(header: Text("Project Name & Password")) {
                    TextField("Enter project name", text: self.$addServerModel.projectName).autocapitalization(.none)
                    
                    SecureField("Enter project password", text: self.$addServerModel.projectPassword)
                }
                
                Button(action: addButton) {
                    Text("Add project")
                }
                .disabled($addServerButtonDisabled.wrappedValue)
                .onReceive(addServerModel.validatedInput) {
                    self.addServerButtonDisabled = !$0
                }
            }
            .modifier(DismissingKeyboard())
    }
    
    func addButton() {
        let project = Project(name: addServerModel.projectName, password: addServerModel.projectPassword, url: addServerModel.serverAddress)
        DataManager.shared.addProject(project)
        self.presentationMode.wrappedValue.dismiss()
    }
}

//struct OnboardingView_Previews: PreviewProvider {
//    static var previews: some View {
//        OnboardingView().environmentObject(ServerManager())
//    }
//}
