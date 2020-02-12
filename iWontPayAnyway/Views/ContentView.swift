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
    var manager = ProjectManager.shared
    
    @State private var name: String = "https:mynextcloud.com"
    
    @State
    var tabBarIndex = tabBarItems.ServerList
    
    var bills = [Bill]()
    
    var body: some View {
        TabView(selection: $tabBarIndex){
            if !manager.projects.isEmpty {
                ProjectList()
                    .tabItem({
                        Image(systemName: "archivebox")
                    }).tag(tabBarItems.ServerList)
                BalanceList(viewModel: BalanceViewModel())
                    .tabItem({
                        Image(systemName: "arrow.right.arrow.left")
                    }).tag(tabBarItems.Balance)
                BillsList(viewModel: BillListViewModel())
                    .tabItem({
                        Image(systemName: "rectangle.stack")
                    }).tag(tabBarItems.BillList)
                AddBillView(tabBarIndex: $tabBarIndex, viewModel: BillListViewModel())
                    .tabItem({
                        Image(systemName: "rectangle.stack.badge.plus")
                    }).tag(tabBarItems.AddBill)
            } else {
                AddProjectView(addProjectModel: AddProjectModel())
                    .tabItem({
                        Image(systemName: "folder.badge.plus")
                    }).tag(tabBarItems.AddServer)
            }
        }.onAppear {
            self.manager.updateProjects()
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

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        serverManager.projects = previewProjects
//        serverManager.selectedProject = previewProject
//        return ContentView().environmentObject(serverManager)
//    }
//}
