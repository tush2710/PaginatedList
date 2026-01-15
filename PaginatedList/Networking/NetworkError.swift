//
//  NetworkError.swift
//  PaginatedList
//
//  Created by Tushar Zade on 15/01/26.
//

enum NetworkError: Error {
    case noInternet
    case invalidURL
    case decodingError
    case serverError(String)
    
    var message: String {
        switch self {
        case .noInternet: return "No internet connection. Please check your network."
        case .invalidURL: return "Invalid URL"
        case .decodingError: return "Failed to parse data"
        case .serverError(let msg): return msg
        }
    }
}
