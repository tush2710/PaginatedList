//
//  ProductsViewModel.swift
//  PaginatedList
//
//  Created by Tushar Zade on 16/01/26.
//
import UIKit
import Combine

protocol ProductsViewModelDelegate: AnyObject {
    func didUpdateProducts()
    func didFailWithError(_ error: NetworkError)
    func didStartLoading()
    func didFinishLoading()
}

class ProductsViewModel {
    weak var delegate: ProductsViewModelDelegate?
    private let networkManager: NetworkManagerProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private(set) var products: [Product] = []
    private var currentPage = 1
    private var totalPages = 1
    private(set) var isLoading = false
    
    init(networkManager: NetworkManagerProtocol = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
    var numberOfProducts: Int {
        return products.count
    }
    
    func product(at index: Int) -> Product {
        return products[index]
    }
    
    var hasMorePages: Bool {
        return currentPage < totalPages
    }
    
    func loadProducts() {
        guard !isLoading else { return }
        
        isLoading = true
        delegate?.didStartLoading()
        
        networkManager.fetchProducts(page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                self.delegate?.didFinishLoading()
                
                if case .failure(let error) = completion {
                    self.delegate?.didFailWithError(error)
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                self.products.append(contentsOf: response.data)
                // Calculate total pages from pagination data
                let total = response.pagination.total
                let limit = response.pagination.limit
                self.totalPages = Int(ceil(Double(total) / Double(limit)))
                self.delegate?.didUpdateProducts()
            }
            .store(in: &cancellables)
    }
    
    func loadNextPage() {
        guard hasMorePages, !isLoading else { return }
        currentPage += 1
        loadProducts()
    }
    
    func retry() {
        currentPage = 1
        totalPages = 1
        products.removeAll()
        cancellables.removeAll()
        loadProducts()
    }
}
