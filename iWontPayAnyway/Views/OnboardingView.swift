//
//  OnboardingView.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 21.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import SwiftUI

struct OnboardingView: View {
    
    @EnvironmentObject
    var serversModel: ServerManager
    
    @State
    var serverAddress = "https://mynextcloud.org"
    
    @State
    var projectName = ""
    
    @State
    var projectPassword = ""
    
    var body: some View {
            Form {
                Text("Add new project").font(.title)
                Section(header: Text("Server Address")) {
                    TextField("Enter server address", text: $serverAddress).autocapitalization(.none).keyboardType(.URL)
                }
                Section(header: Text("Project Name & Password")) {
                    TextField("Enter project name", text: $projectName).autocapitalization(.none)
                    
                    SecureField("Enter project password", text: $projectPassword)
                }
                
                Button(action: addButton) {
                    Text("Add project")
                }
            }
    }
    
    func addButton() {
        let project = Project(name: self.projectName, password: self.projectPassword, url: self.serverAddress)
        CospendNetworkService.instance.getMembers(project: project) {
            successful in
            if successful {
                self.serversModel.addProject(newProject: project)
            } else {
                print("Server wrong")
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView().environmentObject(ServerManager())
    }
}
