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
    
    var manager = DataManager.shared
    
    @State private var name: String = "https:mynextcloud.com"
    
    @State
    var tabBarIndex = tabBarItems.ServerList
    
    var bills = [Bill]()
    
    var body: some View {
        TabView(selection: $tabBarIndex){
            if !manager.projects.isEmpty {
                ServerList()
                    .tabItem({
                        Image(systemName: "archivebox")
                    }).tag(tabBarItems.ServerList)
                BalanceList(viewModel: BalanceViewModel(project: manager.currentProject))
                    .tabItem({
                        Image(systemName: "arrow.right.arrow.left")
                    }).tag(tabBarItems.Balance)
                BillsOverview()
                    .tabItem({
                        Image(systemName: "rectangle.stack")
                    }).tag(tabBarItems.BillList)
                AddBillView(tabBarIndex: $tabBarIndex, viewModel: BillListViewModel())
                    .tabItem({
                        Image(systemName: "rectangle.stack.badge.plus")
                    }).tag(tabBarItems.AddBill)
            } else {
                OnboardingView(addServerModel: AddServerModel())
                    .tabItem({
                        Image(systemName: "folder.badge.plus")
                    }).tag(tabBarItems.AddServer)
            }
        }.onAppear {
            DataManager.shared.updateProjects()
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
