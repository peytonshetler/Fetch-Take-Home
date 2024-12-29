//
//  APIError.swift
//  FetchTakeHome
//
//  Created by Peyton Shetler on 12/28/24.
//

import Foundation

// We could keep creating custom types for different scenarios.
// Ex: Encoding/Decoding errors (if we were encoding), Failed request errors, etc.
enum APIError: Error {
    
    case badURL
    case invalidStatusCode(statusCode: Int)
    case unknown
    
    var message: String? {
        switch self {
        case .badURL:
            return "Bad URL"
        case .invalidStatusCode(let statusCode):
            return "Bad response with status code: \(statusCode)"
        case .unknown:
            return "unknown error"
        }
    }
    
    var title: String {
        return  "Something went wrong."
    }
}

extension APIError: Equatable {
    public static func ==(lhs: APIError, rhs: APIError) -> Bool {

        switch (lhs,rhs) {
        case (.badURL, .badURL):
            return true
        case (.invalidStatusCode(statusCode: let statusCodeA), .invalidStatusCode(statusCode: let statusCodeB)):
            return statusCodeA == statusCodeB
        case (.unknown, .unknown):
            return true
        default:
            return false
        }
    }
}
