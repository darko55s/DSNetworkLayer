//
//  File.swift
//  
//
//  Created by Darko Spasovski on 6.3.24.
//

import Foundation

public protocol Endpoint {
    var request: URLRequest? { get }
    var httpMethod: String { get }
    var httpHeaders: [String: String]? { get }
    var queryItems: [URLQueryItem]? { get }
    var body: [String: Any]? { get }
    var scheme: String { get }
    var host: String { get }
}

typealias AuthenticatedEndpoint = Endpoint & Authenticated

extension Endpoint {
    func request(forEndpoint endpoint: String) -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = endpoint
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod

        request.setValue("no-store", forHTTPHeaderField: "Cache-Control")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let httpHeaders = httpHeaders {
            for (key, value) in httpHeaders {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        if let httpBody = body,
           let jsonData = try? JSONSerialization.data(withJSONObject: httpBody) {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
        }
        return request
    }
}
