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
    
    let staticpath = "/index.php/apps/cospend/api/projects/"
    
    func updateBills(server: Server, project: Project, completion: @escaping ([Bill]) -> ()) {
        guard let url = buildURL(server, project, "bills") else {
            print("Couldn't unwrap url on server \(server.url) with project \(project.name)")
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
    
    func getMembers(server: Server, project: Project) {
        guard let url = buildURL(server, project, "members") else {
            print("Couldn't unwrap url on server \(server.url) with project \(project)")
            return
        }
        
    }
    
    private func buildURL(_ server: Server, _ project: Project, _ suffix: String) -> URL? {
        let path = "\(server.url)\(staticpath)\(project.name)/\(project.password)/\(suffix)"
        print("Building \(path)")
        return URL(string: path)
    }
}
