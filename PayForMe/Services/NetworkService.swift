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
    
    private let cospendStaticPath = "/index.php/apps/cospend/api/projects"
    private let iHateMoneyStaticPath = "/api/projects"
    
    private var currentProject: Project {
        get {
            return ProjectManager.shared.currentProject
        }
    }
    
    let networkActivityPublisher = PassthroughSubject<Bool, Never>()

        
    func loadBillsPublisher(_ project: Project) -> AnyPublisher<[Bill], Never> {
        let request = self.buildURLRequest("bills", params: [:], project: project)
        return URLSession.shared.dataTaskPublisher(for: request)
            .compactMap { data, response -> Data? in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { print("Network Error"); return nil }
                return data
        }
        .decode(type: [Bill].self, decoder: decoder)
        .replaceError(with: [])
        .eraseToAnyPublisher()
    }

    func loadMembersPublisher(_ project: Project) -> AnyPublisher<[Int:Person], Never> {
        let request = buildURLRequest("members", params: [:], project: project)
        return URLSession.shared.dataTaskPublisher(for: request)
            .compactMap { data, response -> Data? in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { print("Network Error"); return nil }
                return data
        }
        .decode(type: [Person].self, decoder: decoder)
        .replaceError(with: [])
        .map {
            members in
            Dictionary(members.map {($0.id, $0)}) {a,_ in a }
        }
        .eraseToAnyPublisher()
    }
    
    func testProject(_ project: Project) -> AnyPublisher<Bool, Never> {
        let request = buildURLRequest("members", params: [:], project: project)
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 200 else { print("Network Error"); return Data.init() }
                return data
            }
            .decode(type: [Person].self, decoder: decoder)
            .replaceError(with:[])
            .map {
                !$0.isEmpty
            }
            .eraseToAnyPublisher()
    }
    
    func postBillPublisher(bill: Bill) -> AnyPublisher<Bool, Never> {
        let request = buildURLRequest("bills", params: bill.paramsFor(currentProject.backend), project: currentProject, httpMethod: "POST")
        return sendBillPublisher(request: request)
    }
    
    func updateBillPublisher(bill: Bill) -> AnyPublisher<Bool, Never> {
        let request = buildURLRequest("bills/\(bill.id)", params: bill.paramsFor(currentProject.backend), project: currentProject, httpMethod: "PUT")
        return sendBillPublisher(request: request)
    }
    
    func deleteBillPublisher(bill: Bill) -> AnyPublisher<Bool, Never> {
        let request = buildURLRequest("bills/\(bill.id)", params: [:], project: currentProject, httpMethod: "DELETE")
        return sendBillPublisher(request: request)
    }
    
    private func sendBillPublisher(request: URLRequest) -> AnyPublisher<Bool, Never> {
                
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, response.statusCode / 100 == 2 else {
                    return false
                }
                return true
            }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
    
    private func baseURLFor(_ project: Project, suffix: String) -> URL {
        switch project.backend {
            case .cospend:
                return project.url.appendingPathComponent("\(cospendStaticPath)/\(project.name)/\(project.password)/\(suffix)")
            case .iHateMoney:
                return project.url.appendingPathComponent("\(iHateMoneyStaticPath)/\(project.name)/\(suffix)")
        }
    }
    
    private func buildURLRequest(_ suffix: String = "", params: [String: Any] = [:], project: Project = ProjectManager.shared.currentProject, httpMethod: String = "GET") -> URLRequest {
        
        let requestURL: URL
        var request: URLRequest
        
        if let cospendParams = params as? [String: String], project.backend == .cospend && !params.isEmpty {
            let baseURL = baseURLFor(project, suffix: suffix)

            var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
            urlComponents?.queryItems = cospendParams.map { URLQueryItem(name: $0, value: $1) }

            requestURL = urlComponents!.url!
        } else {
            requestURL = baseURLFor(project, suffix: suffix)
        }
                
        request = URLRequest(url: requestURL)
        
        if project.backend == .iHateMoney {
            guard let authString = "\(project.name):\(project.password)".data(using: .utf8)?.base64EncodedString() else { fatalError("error generating authString. THIS SHOULD NOT HAPPEN") }
            request.setValue("Basic \(authString)", forHTTPHeaderField: "Authorization")
            
            if !params.isEmpty {
                request.httpBody = try? JSONSerialization.data(withJSONObject: params)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
            }
        }
        
        request.httpMethod = httpMethod
        
        return request
    }
    
    enum HTTPError: LocalizedError {
        case statuscode
    }
    
    enum ServerError: LocalizedError {
        case noIdReturned
    }
}
