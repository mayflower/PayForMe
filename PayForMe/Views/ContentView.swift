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
        
    @State
    var tabBarIndex = tabBarItems.BillList
    
    @State
    var showModal = false
    
    @State
    var hidePlusButton = false
    
    var bills = [Bill]()
    
    var body: some View {
        ZStack {
            TabView(selection: $tabBarIndex){
                if !manager.projects.isEmpty {
                    BillList(viewModel: BillListViewModel(), hidePlusButton: self.$hidePlusButton)
                        .tabItem({
                            Image(systemName: "rectangle.stack")
                        })
                        .tag(tabBarItems.BillList)
                    BalanceList(hidePlusButton: $hidePlusButton, viewModel: BalanceViewModel())
                        .tabItem({
                            Image(systemName: "arrow.right.arrow.left")
                        })
                        .tag(tabBarItems.Balance)
                    ProjectList(hidePlusButton: self.$hidePlusButton)
                        .tabItem({
                            Image(systemName: "gear")
                        })
                        .tag(tabBarItems.ServerList)
                } else {
                    AddProjectView(hidePlusButton: self.$hidePlusButton)
                        .tabItem({
                            Image(systemName: "folder.badge.plus")
                        })
                        .tag(tabBarItems.AddServer)
                }
            }
            
            VStack {
                Spacer()
                Button(action: {
                    self.showModal.toggle()
                }) {
                    if !hidePlusButton {
                        Image(systemName: "plus.circle")
                            .resizable()
                            .frame(width: 64, height: 64)
                            .foregroundColor(Color.secondary)
                            .shadow(radius: 20)
                    } else {
                        EmptyView()
                    }
                }
            }.padding(EdgeInsets(top: 0, leading: 32, bottom: 64, trailing: 32))
        }.sheet(isPresented: $showModal) {
            AddBillView(showModal: self.$showModal)
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
        previewProjects.forEach{
            ProjectManager.shared.addProject($0)
        }
        ProjectManager.shared.currentProject = previewProject
        return ContentView()
    }
}
