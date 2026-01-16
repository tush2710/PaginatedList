//
//  ViewController.swift
//  PaginatedList
//
//  Created by Tushar Zade on 15/01/26.
//

import UIKit
import Combine

class ProductsListViewController: UIViewController {
    @IBOutlet weak var itemListTableVC: UITableView!
    
    private let viewModel = ProductsViewModel()
    private var activityIndicator: UIActivityIndicatorView!
    private var errorView: ErrorView?
    private let footerSpinner = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerTableCell()
        self.addActivityIndicator()
        viewModel.delegate = self
        viewModel.loadProducts()
        
        self.setupFooterSpinner()
    }
    
    private func registerTableCell() {
        itemListTableVC.register(
            UINib(
                nibName: ProductTableViewCell.identifier,
                bundle: nil),
            forCellReuseIdentifier: ProductTableViewCell.identifier
        )
    }
    
    private func addActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    private func setupFooterSpinner() {
        footerSpinner.hidesWhenStopped = true
        footerSpinner.frame = CGRect(x: 0, y: 0, width: itemListTableVC.bounds.width, height: 60)
    }
    
    private func showFooterSpinner() {
        itemListTableVC.tableFooterView = footerSpinner
        footerSpinner.startAnimating()
    }
    
    private func hideFooterSpinner() {
        footerSpinner.stopAnimating()
        itemListTableVC.tableFooterView = nil
    }
    
    private func showError(_ error: NetworkError) {
        errorView?.removeFromSuperview()
        let errView = ErrorView(message: error.message)
        errView.frame = view.bounds
        errView.retryAction = { [weak self] in
            self?.errorView?.removeFromSuperview()
            self?.errorView = nil
            self?.viewModel.retry()
        }
        view.addSubview(errView)
        errorView = errView
    }

}

// MARK: - TableView Delegate & DataSource
extension ProductsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  viewModel.numberOfProducts
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProductTableViewCell.identifier, for: indexPath) as? ProductTableViewCell else {
            return UITableViewCell()
        }
        let product = viewModel.product(at: indexPath.row)
        cell.configure(with: product)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let product = viewModel.product(at: indexPath.row)
        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "ProductDetailViewController") as? ProductDetailViewController else { return }
        detailVC.product = product
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.numberOfProducts - 3 {
            viewModel.loadNextPage()
        }
    }
}

extension ProductsListViewController: ProductsViewModelDelegate {
    func didUpdateProducts() {
        errorView?.removeFromSuperview()
        errorView = nil
        itemListTableVC.reloadData()
        hideFooterSpinner()
    }
    
    func didFailWithError(_ error: NetworkError) {
        hideFooterSpinner()
        if viewModel.numberOfProducts == 0 {
            showError(error)
        }else {
            let alert = UIAlertController(title: "Error", message: error.message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    func didStartLoading() {
        if viewModel.numberOfProducts == 0 {
            activityIndicator.startAnimating()
        } else {
            showFooterSpinner()
        }
    }
    
    func didFinishLoading() {
        activityIndicator.stopAnimating()
    }
}
