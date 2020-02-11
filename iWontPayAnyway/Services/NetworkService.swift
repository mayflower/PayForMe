//
//  CospendNetworkservice.swift
//  iWontPayAnyway
//
//  Created by Max Tharr on 21.01.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import Foundation
import Combine

class NetworkService {
    
    static let shared = NetworkService()
    
    private let decoder: JSONDecoder
    
    private init(){
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.cospend)
    }
    
    let staticpath = "/index.php/apps/cospend/api/projects/"
        
    var loadBillsPublisher: AnyPublisher<[Bill],Never> {
        let url = buildURL(ProjectManager.shared.currentProject, "bills")!
        return URLSession.shared.dataTaskPublisher(for: url)
            .compactMap{
                data, response -> Data? in
                guard let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 200 else { print("Network error"); return nil }
                return data
        }
        .decode(type: [Bill].self, decoder: decoder)
        .replaceError(with: [])
        .eraseToAnyPublisher()
    }
    
    var loadMembersPublisher: AnyPublisher<[Person],Never> {
        let url = buildURL(ProjectManager.shared.currentProject, "members")!
        return URLSession.shared.dataTaskPublisher(for: url)
            .compactMap { data, response -> Data? in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Network Error")
                return nil
            }
            return data
            }
        .decode(type: [Person].self, decoder: JSONDecoder())
        .replaceError(with: [])
        .eraseToAnyPublisher()
    }
    
    func postBillPublisher(bill: Bill) -> AnyPublisher<Bool, Never> {
        let baseURL = buildURL(ProjectManager.shared.currentProject, "bills")!
        return sendBillPublisher(bill: bill, baseURL: baseURL, httpMethod: "POST")
    }
    
    func updateBillPublisher(bill: Bill) -> AnyPublisher<Bool, Never> {
        let baseURL = buildURL(ProjectManager.shared.currentProject, "bills/\(bill.id)")!
        return sendBillPublisher(bill: bill, baseURL: baseURL, httpMethod: "PUT")
    }
    
    private func sendBillPublisher(bill: Bill, baseURL: URL, httpMethod: String) -> AnyPublisher<Bool, Never> {
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        let params = [
            "date": DateFormatter.cospend.string(from: bill.date),
            "what": bill.what,
            "payer": bill.payer_id.description,
            "amount": bill.amount.description,
            "payed_for": bill.owers.map{$0.id.description}.joined(separator: ","),
            "repeat": "n",
            "paymentmode": "n",
            "categoryid": "0"
        ]
        urlComponents?.queryItems = params.map{URLQueryItem(name: $0, value: $1)}
        let url = urlComponents!.url!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                    return false
                }
                return true
            }
            .replaceError(with: false)
            .eraseToAnyPublisher()
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
