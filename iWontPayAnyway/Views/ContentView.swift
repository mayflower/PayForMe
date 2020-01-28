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
    
    @State
    var tabBarIndex = tabBarItems.BillList
    
    var bills = [Bill]()
    
    var body: some View {
        TabView(selection: $tabBarIndex){
            if !serverManager.projects.isEmpty {
                ServerList()
                    .tabItem({
                        Image(systemName: "archivebox")
                    }).tag(tabBarItems.ServerList)
                BillsOverview(viewModel: BillListViewModel(project: serverManager.selectedProject!))
                    .tabItem({
                        Image(systemName: "rectangle.stack")
                    }).tag(tabBarItems.BillList)
                AddBillView(tabBarIndex: $tabBarIndex, viewModel: BillListViewModel(project: serverManager.selectedProject!))
                    .tabItem({
                        Image(systemName: "rectangle.stack.badge.plus")
                    }).tag(tabBarItems.AddBill)
            }
            OnboardingView()
            .tabItem({
                Image(systemName: "folder.badge.plus")
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
        let serverManager = ServerManager()
        serverManager.projects = previewProjects
        serverManager.selectedProject = previewProject
        return ContentView().environmentObject(serverManager)
    }
}
