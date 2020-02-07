//
//  CospendNetworkservice.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 21.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import Foundation
import Combine

class NetworkingManager {
    
    static let shared = NetworkingManager()
    
    private init(){}
    
    let staticpath = "/index.php/apps/cospend/api/projects/"
    
    var cancellables = [AnyCancellable]()
    
    func loadBills(project: Project) {
        guard let url = buildURL(project, "bills") else {
            print("Couldn't unwrap url on server \(project.url) with project \(project.name)")
            return
        }
        let cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .compactMap{
                data, response -> Data? in
                guard let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 200 else { print("Network error"); return nil }
                return data
            }
            .decode(type: [Bill].self, decoder: JSONDecoder())
            .replaceError(with: [])
            .assign(to: \.bills, on: project)
        
        self.cancellables.append(cancellable)
    }
    
    func getMembers(project: Project) {
        guard let url = buildURL(project, "members") else {
            print("Couldn't unwrap url on server \(project.url) with project \(project)")
            return
        }
        
        let cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .compactMap { data, response -> Data? in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Network Error")
                    return nil
                }
                return data
            }
            .decode(type: [Person].self, decoder: JSONDecoder())
            .replaceError(with: [])
            .assign(to: \.members, on: project)
        
        self.cancellables.append(cancellable)
    }
    
    func updateBill(project: Project, bill: Bill, completion: @escaping (Bool, Int?) -> ()) {
        guard let baseURL = buildURL(project, "bills/\(bill.id)") else {
            print("💣 Did not build URL")
            return
        }
        sendBill(project: project, bill: bill, baseURL: baseURL, httpMethod: "PUT")
    }
    
    func postBill(project: Project, bill: Bill, completion: @escaping (Bool, Int?) -> ()) {
        guard let baseURL = buildURL(project, "bills") else {
            print("💣 Did not build URL")
            return
        }
        sendBill(project: project, bill: bill, baseURL: baseURL, httpMethod: "POST")
    }
    
    private func sendBill(project: Project, bill: Bill, baseURL: URL, httpMethod: String) {
        
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        let params = [
            "date": bill.date,
            "what": bill.what,
            "payer": bill.payer_id.description,
            "amount": bill.amount.description,
            "payed_for": bill.owers.map{$0.id.description}.joined(separator: ","),
            "repeat": "n",
            "paymentmode": "n",
            "categoryid": "0"
        ]
        urlComponents?.queryItems = params.map{URLQueryItem(name: $0, value: $1)}
        guard let url = urlComponents?.url else {
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod
        
        let cancellable = URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw HTTPError.statuscode
                }
                guard let idString = String(data: output.data, encoding: .utf8), let id = Int(idString) else {
                    throw ServerError.noIdReturned
                }
                return id
            }
            .replaceError(with: -1)
            .assign(to: \.id, on: bill)
        
        self.cancellables.append(cancellable)
        
    }
    
    func buildURL(_ project: Project, _ suffix: String) -> URL? {
        let path = "\(project.url)\(staticpath)\(project.name)/\(project.password)/\(suffix)"
        print("Building \(path)")
        return URL(string: path)
    }
    
    enum HTTPError: LocalizedError {
        case statuscode
    }
    
    enum ServerError: LocalizedError {
        case noIdReturned
    }
}
