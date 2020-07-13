//
//  ItemTableViewCell.swift
//  QuickShop
//
//  Created by neda niazalizadeh on 2020-06-12.
//  Copyright © 2020 neda niazalizadeh. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemDescription: UILabel!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func generateItem(_ item: Item) {
        itemName.text = item.name
        itemDescription.text = item.description
        itemPrice.text =  converToCurrency(item.price)
        itemPrice.adjustsFontSizeToFitWidth = true
        
        if item.imageLink != nil && item.imageLink.count > 0 {
            
            downloadImages(imageUrls: [item.imageLink.first!]) { (images) in
                self.itemImage.image = images.first as? UIImage
            }
        }
    }
    
}
