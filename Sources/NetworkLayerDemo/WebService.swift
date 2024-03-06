//
//  File.swift
//  
//
//  Created by Darko Spasovski on 6.3.24.
//

import Combine
import Foundation

public protocol WebServiceProtocol {
//    func publisher<T: Decodable>(for endpoint: Endpoint, forceLog: Bool) -> AnyPublisher<T, Error>
    func publisher<T: Codable, E: Codable & Error>(
        endpoint: Endpoint,
        responseDataType: T.Type,
        errorCodesType: E.Type,
        forceLog: Bool
    ) -> AnyPublisher<T, Error>
}

public class WebService: WebServiceProtocol {
    internal let urlSession: URLSession
    internal let jsonDecoder: JSONDecoder
    internal let networkLogger = NetworkLogger()

    let apiQueue = DispatchQueue(label: "NetworkLayerQueue", qos: .default, attributes: .concurrent)

    public init(urlSession: URLSession = URLSession(configuration: URLSessionConfiguration.default), decoder: JSONDecoder = JSONDecoder()) {
        self.urlSession = urlSession
        self.jsonDecoder = decoder
    }
   
    public func publisher<T, E>(endpoint: any Endpoint, responseDataType: T.Type, errorCodesType: E.Type, forceLog: Bool) -> AnyPublisher<T, any Error> where T : Codable, E : Codable, E : Error {
     
        guard let request = endpoint.request else {
            return Fail(error: NetworkError.invalidRequest)
                .eraseToAnyPublisher()
        }
        
        return urlSession
            .dataTaskPublisher(for: request)
            .handleError { [weak self] error in
                self?.networkLogger.logError(error, for: request)
            }
            .mapError { return $0 }
            .subscribe(on: apiQueue)
            .receive(on: DispatchQueue.main)
            .handleOutput { [weak self] tuple in
                self?.networkLogger.logResponse(data: tuple.data, response: tuple.response)
            }
            .map { tuple -> Data in
                return tuple.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error -> Error in
                return NetworkError.parserError(error: error)
            }
            .handleError { [weak self] error in
                self?.networkLogger.logError(error, for: request)
            }
            .eraseToAnyPublisher()
    }
}


public struct MissingValueError: Error {
    static let shared = MissingValueError()
}

public extension Publisher {
    func handleOutput(_ receiveOutput: @escaping ((Self.Output) -> Void)) -> Publishers.HandleEvents<Self> {
        handleEvents(receiveOutput: receiveOutput)
    }

    func handleError(_ receiveError: @escaping ((Self.Failure) -> Void)) -> Publishers.HandleEvents<Self> {
        handleEvents(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                receiveError(error)
            case .finished:
                ()
            }
        })
    }
}
