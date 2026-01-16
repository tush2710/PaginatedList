//
//  ItemTableViewCell.swift
//  PaginatedList
//
//  Created by Tushar Zade on 15/01/26.
//

import UIKit
import Combine

class ProductTableViewCell: UITableViewCell {
    @IBOutlet weak var imgProduct: UIImageView!
    @IBOutlet weak var lblProductTitle: UILabel!
    @IBOutlet weak var lblProductDescription: UILabel!
    @IBOutlet weak var lblProductBrand: UILabel!
    @IBOutlet weak var lblStock: UILabel!
    @IBOutlet weak var lblSpecification: UILabel!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    static let identifier = "ProductTableViewCell"
    private var cancellables = Set<AnyCancellable>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with product: Product) {
        lblProductTitle.text = product.title
        lblProductDescription.text = product.description
        lblProductBrand.text = "Brand: \(product.brand)"
        lblPrice.text = String(format: "$%.2f", product.price)
        
        if let rating = product.rating {
            lblRating.text = "⭐️ \(String(format: "%.1f", rating.rate)) (\(rating.count))"
        }
        
        lblStock.text = "Stock: \(product.stock)"
        lblStock.textColor = product.stock > 50 ? .systemGreen : (product.stock > 20 ? .systemOrange : .systemRed)
        
        var specsText = ""
        if let specs = product.specs {
            var specsParts: [String] = []
            if let color = specs.color { specsParts.append(color) }
            if let storage = specs.storage { specsParts.append(storage) }
            if let battery = specs.battery { specsParts.append("🔋 \(battery)") }
            specsText = specsParts.joined(separator: " • ")
        }
        lblSpecification.text = specsText
        
        imgProduct.image = UIImage(systemName: "photo")
        
        // Cancel previous image loading
        cancellables.removeAll()
        
        if let imageURL = product.image {
            NetworkManager.shared.downloadImage(from: imageURL)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] image in
                    self?.imgProduct.image = image ?? UIImage(systemName: "photo")
                }
                .store(in: &cancellables)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.removeAll()
        imgProduct.image = UIImage(systemName: "photo")
        lblProductTitle.text = nil
        lblProductDescription.text = nil
        lblProductBrand.text = nil
        lblRating.text = nil
        lblStock.text = nil
        lblPrice.text = nil
        lblSpecification.text = nil
    }
}
