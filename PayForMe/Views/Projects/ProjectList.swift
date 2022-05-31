//
//  ServerList.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 22.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import AVFoundation
import SwiftUI

struct ProjectList: View {
    @ObservedObject
    var manager = ProjectManager.shared

    @State private var addProject: AddingProjectMethod?
    @State private var shareProject: Project?

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(manager.projects) { project in
                        listRow(project: project)
                    }
                    .onDelete(perform: deleteProject)
                }
                .sheet(item: $shareProject) { project in
                    ShareProjectQRCode(project: project)
                }
            }
            .navigationBarTitle("Projects")
            .navigationBarItems(trailing:
                HStack {
                    Button(action: {
                        self.addProject = .manual
                    }) {
                        Image(systemName: "plus").fancyStyle()
                    }
                    Button(action: {
                        self.addProject = .qrCode
                    }) {
                        Image(systemName: "qrcode").fancyStyle()
                    }
                }
                .sheet(item: $addProject, content: { method -> AnyView in
                    switch method {
                    case .qrCode:
                        return destination.eraseToAnyView()
                    case .manual:
                        return AddProjectManualView().eraseToAnyView()
                    }
                })
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func listRow(project: Project) -> some View {
        Button(action: {
            self.manager.setCurrentProject(project)
        }, label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(project.name)
                    Text(project.backend == .cospend ? "Cospend" : "iHateMoney").font(.caption).foregroundColor(Color.gray)
                }
                if self.manager.currentProject == project {
                    Image(systemName: "checkmark").padding(.trailing)
                }
                Spacer()
                if project.backend == .cospend {
                    Button(action: {
                        self.shareProject = project
                    }, label: {
                        HStack(spacing: 5) {
                            Image(systemName: "square.and.arrow.up")
                            Image(systemName: "qrcode")
                        }
                    })
                }
            }
        })
    }

    private enum AddingProjectMethod: Int, CaseIterable, Identifiable {
        var id: Int {
            switch self {
            case .qrCode: return 0
            case .manual: return 1
            }
        }

        case qrCode
        case manual
    }

    func deleteProject(at offsets: IndexSet) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            for index in offsets {
                manager.deleteProject(manager.projects[index])
            }
        }
    }

    var destination: some View {
        ProjectQRPermissionCheckerView()
    }
}

struct ServerList_Previews: PreviewProvider {
    static var previews: some View {
        try! ProjectManager.shared.addProject(previewProjects[0])
        try! ProjectManager.shared.addProject(previewProjects[1])
        try! ProjectManager.shared.addProject(previewProjects[2])
        return ProjectList()
    }
}
