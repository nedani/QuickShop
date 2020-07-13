//
//  CategoryCollectionViewCell.swift
//  QuickShop
//
//  Created by neda niazalizadeh on 2020-06-02.
//  Copyright © 2020 neda niazalizadeh. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var catLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    func generateCell(category: Category) {
        
        imageView.image = category.image
        catLabel.text = category.name
    }
}
