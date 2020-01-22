//
//  OnboardingView.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 21.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import SwiftUI

struct OnboardingView: View {
    
    @ObservedObject
    var serversModel: ServerListViewModel
    
    @State
    var serverName = "https://mynextcloud.org"
    
    @State
    var projectName = ""
    
    @State
    var projectPassword = ""
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("Hi, to get you going, please add a server & project").font(.headline)
            Text("Server")
            TextField("Enter server name", text: $serverName)
            Text("Project Name")
            TextField("Enter project name", text: $projectName)
            Text("Project password")
            TextField("Enter project password", text: $projectPassword)
            Button(action: {
                self.serversModel.addServer(server: Server(url: self.serverName, projects: [self.projectName: self.projectPassword]))
            }) {
                Text("Add project")
            }
        }
        .multilineTextAlignment(.center)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(serversModel: ServerListViewModel())
    }
}
