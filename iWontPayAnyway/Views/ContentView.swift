//
//  ContentView.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 21.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import SwiftUI



struct ContentView: View {
    
    @EnvironmentObject
    var serverManager: ServerManager
    
    @State private var name: String = "https:mynextcloud.com"
    
    var bills = [Bill]()
    
    var body: some View {
        TabView {
            if !serverManager.projects.isEmpty {
                ServerList()
                    .tabItem({
                        Image(systemName: "archivebox")
                        Text("Projects")
                    }).tag(tabBarItems.ServerList)
                BillsOverview(viewModel: BillListViewModel(project: serverManager.projects[0]))
                    .tabItem({
                        Image(systemName: "rectangle.stack")
                        Text("Bills")
                    }).tag(tabBarItems.BillList)
            }
            OnboardingView()
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
        return ContentView().environmentObject(ServerManager())
    }
}
