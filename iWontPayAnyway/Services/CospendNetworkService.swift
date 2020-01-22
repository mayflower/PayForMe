//
//  CospendNetworkservice.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 21.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import Foundation

class CospendNetworkService {
    
    static let instance = CospendNetworkService()
    
    private init(){}
    
    func updateBills(server: Server, project: String, completion: @escaping ([Bill]) -> ()) {
        guard let url = URL(string: "\(server.url)/index.php/apps/cospend/api/projects/\(project)/\(server.projects[project]!)/bills") else {
            print("Couldn't unwrap url on server \(server.url) with project \(project)")
            return
        }
        URLSession.shared.dataTask(with: url, completionHandler: {
            data, response, error in
            guard let data = data else {
                print("Could not unwarp data")
                return }
            guard let bills = try? JSONDecoder().decode([Bill].self, from: data) else {
                print("Could not decode data")
                return }
    
            completion(bills)
            }).resume()
    }
}
