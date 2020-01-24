//
//  ServerCell.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 22.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import SwiftUI

struct ServerCell: View {
    
    @State var server: Server
    
    var body: some View {
        NavigationView {
            List {
                ForEach(server.projects, id: \.name) {
                    project in
                    NavigationLink(destination: BillsOverview(server: self.server, project: project)) {
                        Text(project.name)
                    }
                }
            }.navigationBarTitle(server.name)
        }
    }
}

struct ServerCell_Previews: PreviewProvider {
    static var previews: some View {
        let project = Project(name: "test1", password: "test23")
        project.bills = previewBills
        let server = Server(name: "test", url: "https://testserver.mayflower.de", projects: [project])
        return ServerCell(server: server)
    }
}
