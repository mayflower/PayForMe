//
//  ContentView.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 21.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import SwiftUI



struct ContentView: View {
    
    @ObservedObject
    var serversModel = ServerManager()
    
    @State private var name: String = "https:mynextcloud.com"
    
    var bills = [Bill]()
    
    var body: some View {
        TabView(selection: $serversModel.tabBarState) {
            ServerList(serversModel: serversModel)
            .tabItem({
                Image(systemName: "archivebox")
                Text("Servers")
            }).tag(tabBarItems.ServerList)
            OnboardingView(serversModel: serversModel)
            .tabItem({
                Image(systemName: "rectangle.stack.badge.plus")
                Text("Add server")
            }).tag(tabBarItems.AddServer)
        }
    }
}

enum tabBarItems: Int {
    case ServerList
    case BillList
    case AddServer
    case Balance
    case AddBill
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        return ContentView()
    }
}
