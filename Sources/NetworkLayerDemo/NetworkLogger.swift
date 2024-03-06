//
//  File.swift
//  
//
//  Created by Darko Spasovski on 6.3.24.
//

import Foundation

public final class NetworkLogger {

#if DEBUG
    var enabled = true
#else
    var enabled = false
#endif

   public func logRequest(_ request: URLRequest, forceLog: Bool) {
        guard enabled || forceLog else { return }
        let urlString = request.url?.absoluteString ?? ""
        let components = NSURLComponents(string: urlString)

        let method = request.httpMethod != nil ? "\(request.httpMethod!)": ""
        let path = "\(components?.path ?? "")"
        let query = "\(components?.query ?? "")"
        let host = "\(components?.host ?? "")"

        var requestLog = "\n\n---------- REQUEST ---------->\n"
        requestLog += "\(urlString)"
        requestLog += "\n\n"
        requestLog += "\(method) \(path)?\(query) HTTP/1.1\n"
        requestLog += "Host: \(host)\n"
        for (key, value) in request.allHTTPHeaderFields ?? [:] {
            requestLog += "\(key): \(value)\n"
        }
        if let body = request.httpBody {
            let bodyString = NSString(data: body, encoding: String.Encoding.utf8.rawValue) ?? "Can't render body; not utf8 encoded"
            requestLog += "\n\(bodyString)\n"
        }

        requestLog += "\n------------------------->\n\n"
        print(requestLog)
    }

    public func logResponse(data: Data?, response: URLResponse?) {
        guard enabled else { return }

        let urlString = response?.url?.absoluteString
        let components = NSURLComponents(string: urlString ?? "")

        let path = "\(components?.path ?? "")"
        let query = "\(components?.query ?? "")"

        var responseLog = "\n\n<---------- RESPONSE ----------\n"
        if let urlString = urlString {
            responseLog += "\(urlString)"
            responseLog += "\n\n"
        }

        if let httpResponse = response as? HTTPURLResponse {
            responseLog += "HTTP \(httpResponse.statusCode) \(path)?\(query)\n"
            if let host = components?.host {
                responseLog += "Host: \(host)\n"
            }
            for (key, value) in httpResponse.allHeaderFields {
                responseLog += "\(key): \(value)\n"
            }
        }
        if let body = data {
            let bodyString = NSString(data: body, encoding: String.Encoding.utf8.rawValue) ?? "Can't render body; not utf8 encoded"
            responseLog += "\n\(bodyString)\n"
        }

        responseLog += "\n<------------------------\n\n"
        print(responseLog)
    }

    public func logError(_ error: Error?, for request: URLRequest) {
        guard enabled else { return }

        let urlString = request.url?.absoluteString ?? ""
        var errorLog = "\n\n---------- ERROR ----------\n"
        errorLog += "\(urlString)"
        errorLog += "\n\n"

        if let error = error {
            errorLog += "\nError: \(error.localizedDescription)\n"
        }
        errorLog += "\n------------------------\n\n"
        print(errorLog)
    }
}
