//
//  BillsOverview.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 22.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import SwiftUI
import Combine

struct BillsOverview: View {
    
    @State
    var server: Server
    
    @State
    var project: Project
    
    @State
    private var addBills = false
    
    @State
    private var billsLoaded = true
    
    var body: some View {
        VStack {
            Button(action: {
                self.addBills.toggle()
            }) {
                Text("Add Bill")
            }
            if (addBills) {
                AddBillView()
            }
            if billsLoaded {
                List(project.bills) {
                    BillCell(bill: $0)
                }.onAppear(perform: loadBills)
            } else {
                Image(systemName: "arrow.2.circlepath").resizable().frame(width: 50, height: 50)
                Text("Loading Bills, please wait")
            }
        }
    }
    
    func loadBills() {
        let url = CospendNetworkService.instance.buildURL(server, project, "bills")!
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap{
                data, response -> [Bill] in
                guard let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 200 else { print("Network error"); return [] }
                guard let bills = try? JSONDecoder().decode([Bill].self, from: data) else {
                    print ("Data unwrap error")
                    return []
                }
                return bills
        }
        .replaceError(with: [])
        .receive(on: DispatchQueue.main)
        .assign(to: \.project.bills, on: self)
        
        CospendNetworkService.instance.updateBills(server: server, project: project, completion: {
            bills in
            print("Test")
            self.project.bills = bills
            self.billsLoaded = true
            print("Test")
        })
    }
}

struct BillsOverview_Previews: PreviewProvider {
    static var previews: some View {
        let project = Project(name: "TestProject", password: "TestPassword")
        project.bills = previewBills
        let server = Server(name: "test", url: "https://testserver.mayflower.de", projects: [project])
        return BillsOverview(server: server, project: project)
    }
}
