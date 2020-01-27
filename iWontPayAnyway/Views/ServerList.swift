//
//  ServerList.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 22.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import SwiftUI

struct ServerList: View {
    @ObservedObject
    var serversModel: ServerManager
    
    @State
    private var bills: [Bill] = []
    @State
    private var current: Int? = nil
    
    var body: some View {
        VStack {
            HStack(spacing: 50) {
                Text("Known Servers")
                Button(action: {
                    self.serversModel.eraseServers()
                }, label: {
                    Text("Erase all")
                    Image(systemName: "trash")
                })
            }
            VStack {
                ForEach(serversModel.servers, id: \.url) {
                    server in
                    ServerCell(server: server)
                }
            }
        }
    }
}

struct ServerList_Previews: PreviewProvider {
    static var previews: some View {
        let serversModel = ServerManager()
        let server = Server(name: "test", url: "https://testserver.mayflower.de", projects: [
            Project(name: "test1", password: "test23"),
            Project(name: "test2", password: "test45"),
        ])
        serversModel.addServer(newServer: server)
        return ServerList(serversModel: serversModel)
    }
}
