//
//  ServerList.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 22.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import SwiftUI
import AVFoundation

struct ProjectList: View {
    
    @ObservedObject
    var manager = ProjectManager.shared
    
    @State private var addProject: AddingProjectMethod?
    @State private var shareProject: Project?
    
    var body: some View {
        VStack {
            header
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
    }
    
    private func listRow(project: Project) -> some View {
        Button(action: {
            self.manager.setCurrentProject(project)
        }, label: {
            HStack {
                VStack {
                    Text(project.name)
                    Text(project.backend == .cospend ? "Cospend" : "iHateMoney").font(.caption).foregroundColor(Color.gray)
                }
                if project.backend == .cospend {
                    Spacer()
                    Button(action: {
                        self.shareProject = project
                    }, label: {
                        HStack(spacing: 5) {
                            Image(systemName: "square.and.arrow.up")
                            Image(systemName: "qrcode")
                        }
                    })
                }
                Spacer()
                if self.manager.currentProject == project {
                    Image(systemName: "checkmark").padding(.trailing)
                }
            }
        })
    }
    
    private var header: some View {
        HStack(spacing: 20) {
            Spacer()
            Button(action: { addProject = .manual }) {
                Image(systemName: "plus").fancyStyle()
                
            }
            Button(action: { addProject = .qrCode }) {
                Image(systemName: "qrcode").fancyStyle()
                
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 5)
        .sheet(item: $addProject, content: { method -> AnyView in
            switch method {
                case .qrCode:
                    return destination.eraseToAnyView()
                case .manual:
                    return AddProjectManualView().eraseToAnyView()
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
        for index in offsets {
            manager.deleteProject(manager.projects[index])
        }
    }
    
    var destination: some View {
        ProjectQRPermissionCheckerView()
    }
}

struct ServerList_Previews: PreviewProvider {
    static var previews: some View {
        ProjectManager.shared.addProject(previewProjects[0])
        ProjectManager.shared.addProject(previewProjects[1])
        return ProjectList()
    }
}
