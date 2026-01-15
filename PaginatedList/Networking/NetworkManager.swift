//
//  NetworkManager.swift
//  PaginatedList
//
//  Created by Tushar Zade on 15/01/26.
//

import UIKit
import Combine

protocol NetworkManagerProtocol {
    func fetchProducts(page: Int) -> AnyPublisher<ProductResponse, NetworkError>
    func downloadImage(from url: String) -> AnyPublisher<UIImage?, Never>
}

class NetworkManager: NetworkManagerProtocol {
    static let shared = NetworkManager()
    private let imageCache = NSCache<NSString, UIImage>()
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    func fetchProducts(page: Int) -> AnyPublisher<ProductResponse, NetworkError> {
        guard Reachability.isConnectedToNetwork() else {
            return Fail(error: NetworkError.noInternet)
                .eraseToAnyPublisher()
        }
        
        let urlString = "https://fakeapi.net/products?page=\(page)&limit=10&category=electronics"
        guard let url = URL(string: urlString) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.serverError("Invalid response")
                }
                return data
            }
            .decode(type: ProductResponse.self, decoder: JSONDecoder())
            .mapError { error -> NetworkError in
                if error is DecodingError {
                    return .decodingError
                }
                return .serverError(error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
    
    func downloadImage(from urlString: String) -> AnyPublisher<UIImage?, Never> {
        let cacheKey = NSString(string: urlString)
        
        if let cachedImage = imageCache.object(forKey: cacheKey) {
            return Just(cachedImage)
                .eraseToAnyPublisher()
        }
        
        guard let url = URL(string: urlString) else {
            return Just(nil)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { data, _ -> UIImage? in
                guard let image = UIImage(data: data) else { return nil }
                self.imageCache.setObject(image, forKey: cacheKey)
                return image
            }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
}
