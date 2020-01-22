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
    var serversModel: ServerListViewModel
    
    @State
    private var bills: [Bill] = []
    @State
    private var current: Int? = nil
    
    var body: some View {
        
        NavigationView {
            VStack {
                NavigationLink(destination: BillsOverview(bills: bills), tag: 1, selection: $current) {
                    EmptyView()
                }
                Text("Known Servers")
                List {
                    ForEach(serversModel.servers, id: \.url) {
                        server in
                        ServerCell(server: server) {
                            project in
                            print("Projekt: \(project)")
                            CospendNetworkService.instance.updateBills(server: server, project: project) { (bills) in
                                self.bills = bills
                                self.current = 1
                            }
                        }
                    }
                }
            }
            Button(action: {
                self.serversModel.addingServer = true
            }) {
                Text("Add server")
            }
        }
    }
}

struct ServerList_Previews: PreviewProvider {
    static var previews: some View {
        let serversModel = ServerListViewModel()
        let server = Server(url: "https://testserver.mayflower.de", projects: [
            "test":"test123",
            "test2":"test45",
        ])
        serversModel.addServer(server: server)
        return ServerList(serversModel: serversModel)
    }
}
