//
//  ServerList.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 22.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import SwiftUI

struct ProjectList: View {
    
    @ObservedObject
    var manager = ProjectManager.shared
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(manager.projects) { project in
                        Button(action: {
                            self.manager.setCurrentProject(project)
                        }, label: {
                            HStack {
                                Text(project.name)
                                if self.manager.currentProject == project {
                                    Spacer()
                                    Image(systemName: "checkmark").padding(.trailing)
                                }
                            }
                        })
                    }
                    .onDelete(perform: deleteProject)
                }
            }.navigationBarItems(trailing:
                NavigationLink(destination: ProjectDetailView(addProjectModel: AddProjectModel())) {
                    Image(systemName: "plus")
                        .frame(width: 20.0, height: 20.0)
                }
            )
            .navigationBarTitle("Known Projects")
        }
    }
    
    func deleteProject(at offsets: IndexSet) {
        for index in offsets {
            manager.deleteProject(manager.projects[index])
        }
    }
}

struct ServerList_Previews: PreviewProvider {
    static var previews: some View {
        ProjectList()
    }
}
