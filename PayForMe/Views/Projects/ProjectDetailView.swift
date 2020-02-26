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
    var addProjectModel = AddProjectModel.shared
    
    @State
    var addProjectButtonDisabled = true
    
    @State
    var showConnectionIndicator = false
    
    @Binding
    var hidePlusButton: Bool
    
    var body: some View {
        VStack {
            Form {
                Picker(selection: $addProjectModel.projectType, label: Text("snens")) {
                    Text("Cospend").tag(ProjectBackend.cospend)
                    Text("iHateMoney").tag(ProjectBackend.iHateMoney)
                }.pickerStyle(SegmentedPickerStyle())
                if self.addProjectModel.projectType == .cospend {
                    Section(header: Text("Server Address")) {
                        TextFieldContainer("https://mynextcloud.org",
                                           text: self.$addProjectModel.serverAddress)
//                            .autocapitalization(.none).keyboardType(.URL)
                            .onTapGesture {
                                if self.addProjectModel.serverAddress.isEmpty {
                                    DispatchQueue.main.async {
                                        self.addProjectModel.serverAddress = "https://"
                                    }
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
            }
            .scaledToFit()
            .onReceive(addProjectModel.connectionInProgress) {
                self.showConnectionIndicator = $0.1
                self.addProjectButtonDisabled = $0.1
            }
            if showConnectionIndicator {
                HStack {
                    Text("Testing server").font(.headline)
                    LoadingDots()
                }
            }
            FancyButton(isDisabled: $addProjectButtonDisabled, action: addButton, text: "Add Project")
            Spacer()
            
        }
        .navigationBarTitle("Add Project")
        .onAppear {
            self.hidePlusButton = true
        }
        .onDisappear {
            self.hidePlusButton = false
        }
        .background(Color.PFMBackground)
    }
    
    func addButton() {
        
        let project: Project
        
        if addProjectModel.projectType == .cospend {
            guard let url = URL(string: addProjectModel.serverAddress) else { return }
            project = Project(name: addProjectModel.projectName, password: addProjectModel.projectPassword, backend: .cospend, url: url)
        } else {
            project = Project(name: addProjectModel.projectName, password: addProjectModel.projectPassword, backend: .iHateMoney)
        }
        
        ProjectManager.shared.addProject(project)
        addProjectModel.reset()
        
        self.presentationMode.wrappedValue.dismiss()
    }
    
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectDetailView(addProjectModel: AddProjectModel.shared, hidePlusButton: .constant(false))
    }
}
