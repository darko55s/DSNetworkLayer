//
//  File.swift
//  
//
//  Created by Darko Spasovski on 6.3.24.
//

import Combine
import Foundation

public final class AuthenticatedWebService: WebService {
 
    private let tokenProvider: AnyPublisher<String, Error>

    public init(tokenProvider: AnyPublisher<String, Error>,
         urlSession: URLSession = URLSession(configuration: URLSessionConfiguration.default),
         decoder: JSONDecoder = JSONDecoder()
    ) {
        self.tokenProvider = tokenProvider
        super.init(urlSession: urlSession, decoder: decoder)
    }

    func publisher<T: Codable, E: Codable & Error>(
        endpoint: AuthenticatedEndpoint,
        responseDataType: T.Type,
        errorCodesType: E.Type,
        forceLog: Bool = false
    ) -> AnyPublisher<T, Error> {
        guard let request = endpoint.request else {
            return Fail(error: NetworkError.invalidRequest)
                .eraseToAnyPublisher()
        }

        networkLogger.logRequest(request, forceLog: forceLog)

        return
            tokenProvider.flatMap { [urlSession] userToken -> AnyPublisher<(data: Data, response: URLResponse), Error> in
                let authRequest = endpoint.addAuthHeaders(request, for: userToken)
                return urlSession.dataTaskPublisher(for: authRequest)
                    .handleError { [weak self] error in
                        self?.networkLogger.logError(error, for: authRequest)
                    }
                    .mapError { return $0 }
                    .eraseToAnyPublisher()
            }
            .subscribe(on: apiQueue)
            .receive(on: DispatchQueue.main)
            .handleOutput { [weak self] tuple in
                self?.networkLogger.logResponse(data: tuple.data, response: tuple.response)
            }
            .map { tuple -> Data in
                return tuple.data
            }
            .decode(type: APIResponse<T, E>.self, decoder: JSONDecoder())
            .mapError { error -> Error in
                return NetworkError.parserError(error: error)
            }
            .tryMap { response in
                // In the case of error, "data" will be empty so we need to check for errors first
                if response.errors?.isEmpty == false,
                   let error = response.errors?.first,
                   let code = error.code {
                    throw code
                }
                // The server always sends a dictionary with data if there are no errors, although
                // many times it is empty so EmptyResponse is most likely.
                if let data = response.data {
                    return data
                }
                assertionFailure("Network request is not sending error or data. Reach out to server to fix")
                throw MissingValueError.shared
            }
            .handleError { [weak self] error in
                self?.networkLogger.logError(error, for: request)
            }
            .eraseToAnyPublisher()
    }
}