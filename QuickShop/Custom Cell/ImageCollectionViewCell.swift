//
//  ImageCollectionViewCell.swift
//  QuickShop
//
//  Created by neda niazalizadeh on 2020-06-12.
//  Copyright © 2020 neda niazalizadeh. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var itemImages: UIImageView!
    
    func showImages(itemImage: UIImage) {
        
        itemImages.image = itemImage
    }
    
}
