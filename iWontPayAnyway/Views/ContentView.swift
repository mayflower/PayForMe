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
    var serversModel = ServerListViewModel()
    
    @State private var name: String = "https:mynextcloud.com"
    
    var bills = [Bill]()
    
    var body: some View {
        Group {
            if serversModel.showServerAdding() {
                OnboardingView(serversModel: serversModel)
            } else {
                ServerList(serversModel: serversModel)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        return ContentView()
    }
}
