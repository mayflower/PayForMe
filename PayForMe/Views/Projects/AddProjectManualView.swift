//
//  OnboardingView.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 21.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import SwiftUI
import Combine

struct AddProjectManualView: View {
    
    @Environment(\.presentationMode)
    var presentationMode: Binding<PresentationMode>
    
    @StateObject
    private var addProjectModel = AddProjectManualViewModel()
    
    @State
    var addProjectButtonDisabled = true
    
    @State
    var showConnectionIndicator = false
    
    @State
    var errorText = ""
    
    var body: some View {
        VStack {
            Text("Add project").font(.title)
            Picker(selection: $addProjectModel.projectType.animation(), label: Text("snens")) {
                Text("Cospend").tag(ProjectBackend.cospend)
                Text("iHateMoney").tag(ProjectBackend.iHateMoney)
            }.pickerStyle(SegmentedPickerStyle())
                .padding(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 8))
            
//            if addProjectModel.projectType == ProjectBackend.iHateMoney {
//                Picker(selection: $addProjectModel.addOrCreate, label: Text("snens")) {
//                    Text("Add Existing").tag(0)
//                    Text("Create New").tag(1)
//                }
//                .pickerStyle(SegmentedPickerStyle())
//                .padding(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 8))
//                .animation(.easeInOut)
//            }
            Form {
                Section(
                    header: Text("Server Address" + (addProjectModel.projectType == .iHateMoney ? " (Optional)" : ""))
                ) {
                    TextFieldContainer(
                        addProjectModel.projectType == .cospend
                            ? "https://mynextcloud.org" : "https://ihatemoney.org",
                        text: self.$addProjectModel.serverAddress)
                        .autocapitalization(.none).keyboardType(.URL)
                        .onTapGesture {
                            if self.addProjectModel.serverAddress.isEmpty {
                                DispatchQueue.main.async {
                                    self.addProjectModel.serverAddress = "https://"
                                }
                            }
                    }
                }
                .animation(.easeInOut)

                Section(header: Text("Project ID & Password")) {
                    if addProjectModel.addOrCreate == 1 && addProjectModel.projectType == .iHateMoney {
                        TextField("Enter your email", text: self.$addProjectModel.emailAddr).autocapitalization(.none)
                            .keyboardType(.emailAddress)
                    }
                    TextField("Enter project id",
                              text: self.$addProjectModel.projectName)
                        .autocapitalization(.none)
                    
                    SecureField("Enter project password", text: self.$addProjectModel.projectPassword)
                }
            }
            .id(addProjectModel.projectType == .cospend ? "cospend" : "iHateMoney")
                
            .frame(width: UIScreen.main.bounds.width, height: 220, alignment: .center)
            Text(errorText).onReceive(addProjectModel.errorTextPublisher) {
                text in
                self.errorText = text
            }
            FancyLoadingButton(isLoading: $addProjectModel.validationProgress,
                        add: false,
                        action: addButton,
                        text:
                addProjectModel.addOrCreate == 0 || addProjectModel.projectType == .cospend ? "Add Project" : "Create Project")
                .disabled(addProjectButtonDisabled)
            Spacer()
            
        }
        .padding(.vertical, 50)
        .background(Color.PFMBackground)
        .edgesIgnoringSafeArea(.all)
    }
    
    func addButton() {
        let project : Project
        if let url = URL(string: addProjectModel.serverAddress) {
            project = Project(name: addProjectModel.projectName, password: addProjectModel.projectPassword, backend: addProjectModel.projectType, url: url)
        } else {
            project = Project(name: addProjectModel.projectName, password: addProjectModel.projectPassword, backend: addProjectModel.projectType)
        }
                
        if addProjectModel.addOrCreate == 0 {
            ProjectManager.shared.addProject(project)
            addProjectModel.reset()
        } else {
            ProjectManager.shared.createProject(project, email: self.addProjectModel.emailAddr) {
                self.addProjectModel.reset()
            }
        }
        
        self.presentationMode.wrappedValue.dismiss()
    }
    
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        AddProjectManualView().environment(\.locale, .init(identifier: "de"))
    }
}
