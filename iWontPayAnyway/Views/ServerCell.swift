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
    @State var completion: (_ project: Project) -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(server.url).font(.headline)
            HStack(alignment: .top) {
                Text("Projects").font(.subheadline)
                Spacer()
                VStack(alignment: .trailing, spacing: 5) {
                   ForEach(server.projects, id: \.name) {
                        project in
                    Button(action: {
                        print(project)
                        self.completion(project)
                    }) {
                        Text(project.name)
                        }
                    }
                }
            }
        }
    }
}

struct ServerCell_Previews: PreviewProvider {
    static var previews: some View {
        let server = Server(url: "https://testserver.mayflower.de", projects: [
            Project(name: "test1", password: "test23"),
            Project(name: "test2", password: "test45"),
        ])
        return ServerCell(server: server, completion: {print($0)})
    }
}
