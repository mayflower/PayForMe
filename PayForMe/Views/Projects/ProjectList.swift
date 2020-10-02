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
    
    @Binding
    var hidePlusButton: Bool
    
    @State
    var cameraAuthStatus = AVCaptureDevice.authorizationStatus(for: .video)
    
    @State private var addProject: AddingProjectMethod?
    
    var body: some View {
        VStack {
            HStack(spacing: 20) {
                Spacer()
                Button(action: { addProject = .manual }) {
                    Image(systemName: "plus").fancyStyle()
                    
                }
                Button(action: { addProject = .qrCode }) {
                    Image(systemName: "qrcode").fancyStyle()
                    
                }
            }.padding(20)
            List {
                ForEach(manager.projects) { project in
                    Button(action: {
                        self.manager.setCurrentProject(project)
                    }, label: {
                        HStack {
                            VStack {
                                Text(project.name)
                                Text(project.backend == .cospend ? "Cospend" : "iHateMoney").font(.caption).foregroundColor(Color.gray)
                            }
                            if self.manager.currentProject == project {
                                Spacer()
                                Image(systemName: "checkmark").padding(.trailing)
                            }
                        }
                    })
                }
                .onDelete(perform: deleteProject)
            }
        }
        .sheet(item: $addProject, content: { method -> AnyView in
            switch method {
                case .qrCode:
                    return destination
                case .manual:
                    return ProjectDetailView(addProjectModel: AddProjectModel.shared, hidePlusButton: self.$hidePlusButton).eraseToAnyView()
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
    
    var destination: AnyView {
        switch cameraAuthStatus {
            case .authorized:
                return AddProjectQRView().eraseToAnyView()
            case .denied:
                return ProjectDetailView(addProjectModel: AddProjectModel.shared, hidePlusButton: self.$hidePlusButton).eraseToAnyView()
            default:
                AVCaptureDevice.requestAccess(for: .video) { _ in
                    cameraAuthStatus = AVCaptureDevice.authorizationStatus(for: .video)
                }
                return Text("Please allow us to use the camera in order to scan the CoSpend QR view").eraseToAnyView()
        }
    }
}

struct ServerList_Previews: PreviewProvider {
    static var previews: some View {
        ProjectManager.shared.addProject(previewProjects[0])
        ProjectManager.shared.addProject(previewProjects[1])
        return ProjectList(hidePlusButton: .constant(false))
    }
}
