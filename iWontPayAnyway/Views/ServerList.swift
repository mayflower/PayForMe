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
            Text("Known projects").font(.title)
            List {
                ForEach(serversModel.projects) { project in
                    Button(action: {
                        self.serversModel.selectedProject = project
                    }, label: {
                        HStack {
                            Text(project.name)
                            if self.serversModel.selectedProject == project {
                                Spacer()
                                Image(systemName: "checkmark").padding(.trailing)
                            }
                        }
                    })
                }
                .onDelete(perform: deleteProject)
            }
        }
    }
    
    func deleteProject(at offsets: IndexSet) {
        for index in offsets {
            serversModel.removeProject(project: serversModel.projects[index])
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
