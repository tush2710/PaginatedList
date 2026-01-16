//
//  ProductDetailViewController.swift
//  PaginatedList
//
//  Created by Tushar Zade on 16/01/26.
//

import UIKit
import Combine

class ProductDetailViewController: UIViewController {

    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var stockLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingCountLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var specsStackView: UIStackView!
    @IBOutlet weak var descriptionLabel: UILabel!
        
    private var cancellables = Set<AnyCancellable>()
    var product: Product!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure()
    }

    private func configure() {
        titleLabel.text = product.title
        brandLabel.text = "Brand: \(product.brand)"
        categoryLabel.text = "📦 \(product.category.capitalized)"
        priceLabel.text = String(format: "$%.2f", product.price)
        descriptionLabel.text = product.description
        
        // Stock
        stockLabel.text = "Stock: \(product.stock)"
        stockLabel.textColor = product.stock > 50 ? .systemGreen : (product.stock > 20 ? .systemOrange : .systemRed)
        
        // Rating
        if let rating = product.rating {
            ratingLabel.text = "⭐️ \(String(format: "%.1f", rating.rate))"
            ratingCountLabel.text = "(\(rating.count) reviews)"
        }
        
        // Specs
        specsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if let specs = product.specs {
            let specsTitle = createSpecLabel(text: "Specifications", isBold: true)
            specsStackView.addArrangedSubview(specsTitle)
            
            if let color = specs.color {
                specsStackView.addArrangedSubview(createSpecLabel(text: "Color: \(color)"))
            }
            if let weight = specs.weight {
                specsStackView.addArrangedSubview(createSpecLabel(text: "Weight: \(weight)"))
            }
            if let storage = specs.storage {
                specsStackView.addArrangedSubview(createSpecLabel(text: "Storage: \(storage)"))
            }
            if let battery = specs.battery {
                specsStackView.addArrangedSubview(createSpecLabel(text: "Battery: \(battery)"))
            }
            if let waterproof = specs.waterproof {
                specsStackView.addArrangedSubview(createSpecLabel(text: "Waterproof: \(waterproof ? "Yes" : "No")"))
            }
            if let screen = specs.screen {
                specsStackView.addArrangedSubview(createSpecLabel(text: "Screen: \(screen)"))
            }
            if let ram = specs.ram {
                specsStackView.addArrangedSubview(createSpecLabel(text: "RAM: \(ram)"))
            }
            if let connection = specs.connection {
                specsStackView.addArrangedSubview(createSpecLabel(text: "Connection: \(connection)"))
            }
            if let capacity = specs.capacity {
                specsStackView.addArrangedSubview(createSpecLabel(text: "Capacity: \(capacity)"))
            }
            if let output = specs.output {
                specsStackView.addArrangedSubview(createSpecLabel(text: "Output: \(output)"))
            }
        }
        
        productImageView.image = UIImage(systemName: "photo")
        
        if let imageURL = product.image {
            NetworkManager.shared.downloadImage(from: imageURL)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] image in
                    self?.productImageView.image = image ?? UIImage(systemName: "photo")
                }
                .store(in: &cancellables)
        }
    }
    
    private func createSpecLabel(text: String, isBold: Bool = false) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = isBold ? .systemFont(ofSize: 18, weight: .semibold) : .systemFont(ofSize: 16)
        label.textColor = isBold ? .label : .secondaryLabel
        return label
    }
}
