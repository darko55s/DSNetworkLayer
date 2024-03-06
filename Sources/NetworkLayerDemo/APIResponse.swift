//
//  File.swift
//  
//
//  Created by Darko Spasovski on 6.3.24.
//

import Foundation

public struct APIResponse<T: Codable, E: Error & Codable>: Codable {
    let errors: [ErrorModel<E>]?
    let data: T?
}

public struct ErrorModel<E: Error & Codable>: Codable {
    let code: E?
    let message: String?
}
