//
//  APIError.swift
//  FetchTakeHome
//
//  Created by Peyton Shetler on 12/28/24.
//

import Foundation

// We could keep creating custom cases for all kinds of different errors
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
