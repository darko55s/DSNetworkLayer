//
//  Created by Darko Spasovski on 6.3.24.
//

import Foundation

public enum NetworkError: Error {
    case invalidRequest
    case dataMissing
    case responseError(error: Error)
    case parserError(error: Error)
    case unauthorized
    case noConnection
}

