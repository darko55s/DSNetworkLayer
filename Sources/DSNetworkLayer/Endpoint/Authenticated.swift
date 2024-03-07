//
//  Created by Darko Spasovski on 6.3.24.
//

import Foundation

public protocol Authenticated {}

public extension Authenticated {
    func addAuthHeaders(_ request: URLRequest, for userToken: String) -> URLRequest {
        var newRequest = request
        newRequest.setValue(userToken, forHTTPHeaderField: "Authorization")
        return newRequest
    }
}
