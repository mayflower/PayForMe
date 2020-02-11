//
//  OnboardingView.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 21.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import SwiftUI
import Combine

struct AddProjectView: View {
    
    @Environment(\.presentationMode)
    var presentationMode: Binding<PresentationMode>
    
    @ObservedObject
    var addServerModel: AddServerModel
    
    @State
    var addServerButtonDisabled = true
    
    var body: some View {
        NavigationView {
            Form {
                Text("Add new project").font(.title)
                Section(header: Text("Server Address")) {
                    TextField("https://mynextcloud.org", text: self.$addServerModel.serverAddress).autocapitalization(.none).keyboardType(.URL)
                }
                Section(header: Text("Project Name & Password")) {
                    TextField("Enter project name", text: self.$addServerModel.projectName).autocapitalization(.none)
                    
                    SecureField("Enter project password", text: self.$addServerModel.projectPassword)
                }
                Section {
                    Button(action: self.addButton) {
                        Text("Add project")
                    }
                    .disabled($addServerButtonDisabled.wrappedValue)
                    .onReceive(addServerModel.validatedInput) {
                        self.addServerButtonDisabled = !$0
                    }
                }
            }
        }
    }
    
    func addButton() {
        let project = Project(name: addServerModel.projectName, password: addServerModel.projectPassword, url: addServerModel.serverAddress)
        ProjectManager.shared.addProject(project)
        self.presentationMode.wrappedValue.dismiss()
    }
}

//struct OnboardingView_Previews: PreviewProvider {
//    static var previews: some View {
//        OnboardingView().environmentObject(ServerManager())
//    }
//}
