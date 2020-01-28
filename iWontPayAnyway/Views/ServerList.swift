//
//  ServerList.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 22.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import SwiftUI

struct ServerList: View {
    @EnvironmentObject
    var serversModel: ServerManager
    
    @State
    private var current: Int? = nil {
        didSet {
            print(_current)
        }
    }

    
    var body: some View {
        VStack {
                Button(action: {
                    self.serversModel.eraseServers()
                }, label: {
                    Text("Erase all")
                    Image(systemName: "trash")
                })
            List(serversModel.projects, selection: $current) {
                project in
                Text(project.name)
            }
        }
    }
}

struct ServerList_Previews: PreviewProvider {
    static var previews: some View {
        let serversModel = ServerManager()
        for project in previewProjects {
            serversModel.addProject(newProject: project)
        }
        return ServerList().environmentObject(serversModel)
    }
}
