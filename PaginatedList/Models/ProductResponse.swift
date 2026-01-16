//
//  ProductResponse.swift
//  PaginatedList
//
//  Created by Tushar Zade on 16/01/26.
//

struct ProductResponse: Codable {
    let data: [Product]
    let pagination: Pagination
}

struct Pagination: Codable {
    let page: Int
    let limit: Int
    let total: Int
}

struct Specs: Codable {
    let color: String?
    let weight: String?
    let storage: String?
    let battery: String?
    let waterproof: Bool?
    let screen: String?
    let ram: String?
    let connection: String?
    let capacity: String?
    let output: String?
}

struct Rating: Codable {
    let rate: Double
    let count: Int
}

struct Product: Codable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let category: String
    let brand: String
    let stock: Int
    let image: String?
    let specs: Specs?
    let rating: Rating?
}
