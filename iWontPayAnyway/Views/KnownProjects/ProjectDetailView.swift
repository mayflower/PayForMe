//
//  OnboardingView.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 21.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import SwiftUI
import Combine

struct ProjectDetailView: View {
    
    @Environment(\.presentationMode)
    var presentationMode: Binding<PresentationMode>
    
    @ObservedObject
    var addProjectModel: AddProjectModel
    
    @State
    var addProjectButtonDisabled = true
    
    
    var body: some View {
        Form {
            Picker(selection: $addProjectModel.projectType, label: Text("snens")) {
                Text("Cospend").tag(ProjectBackend.cospend)
                Text("iHateMoney").tag(ProjectBackend.iHateMoney)
            }.pickerStyle(SegmentedPickerStyle())
            if self.addProjectModel.projectType == .cospend {
                Section(header: Text("Server Address")) {
                    TextFieldContainer("https://mynextcloud.org",
                                       text: self.$addProjectModel.serverAddress)
                        .autocapitalization(.none).keyboardType(.URL)
                        .onTapGesture {
                            if self.addProjectModel.serverAddress.isEmpty {
                                self.addProjectModel.serverAddress = "https://"
                            }
                    }
                }
            }
            Section(header: Text("Project Name & Password")) {
                TextField("Enter project name",
                          text: self.$addProjectModel.projectName)
                    .autocapitalization(.none)

                SecureField("Enter project password", text: self.$addProjectModel.projectPassword)
            }
            if addProjectModel.networkTestInProgress {
                Text("Confirming project")
            }
            Section {
                Button(action: self.addButton) {
                    Text("Add project")
                }
                .disabled($addProjectButtonDisabled.wrappedValue)
                .onReceive(addProjectModel.validatedServer) {
                    self.addProjectButtonDisabled = !$0
                }
            }
        }
        .navigationBarTitle("Add Project")
    }
    
    func addButton() {
        
        guard let url = URL(string: addProjectModel.serverAddress) else { return }
        
        let project = Project(name: addProjectModel.projectName, password: addProjectModel.projectPassword, url: url)
        ProjectManager.shared.addProject(project)
        self.presentationMode.wrappedValue.dismiss()
    }
    
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectDetailView(addProjectModel: AddProjectModel())
    }
}
