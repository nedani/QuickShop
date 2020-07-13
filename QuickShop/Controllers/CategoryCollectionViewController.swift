//  CategoryCollectionViewController.swift
//  QuickShop
//
//  Created by neda niazalizadeh on 2020-06-02.
//  Copyright © 2020 neda niazalizadeh. All rights reserved.


import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class CategoryCollectionViewController: UICollectionViewController {
    
    var categoryArray : [Category] = []
    private let itemPerRow : CGFloat = 3
    private let sectionInsets = UIEdgeInsets(top: 20.0, left: 10.0, bottom: 20.0, right: 10.0)
    
    
    //MARK:- lifeCycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadCategories()
    }
    
    func loadCategories() {
        
        downloadCategoriesFromFirebase { (allCategories) in

            self.categoryArray = allCategories
            self.collectionView.reloadData()
        }
    }
    // MARK:- UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CategoryCollectionViewCell
        
        cell.generateCell(category: categoryArray[indexPath.row])
        
        return cell
    }
    
    //MARK:- UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "categoryToItems", sender: categoryArray[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "categoryToItems" {
            let destination = segue.destination as! ItemsTableViewController
            destination.category = (sender as! Category)
        }
    }
}

// MARK:- collectionViewDelegate
extension CategoryCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemPerRow + 1)
        let availableSpace = view.frame.width - paddingSpace
        let widthPerItem = availableSpace / itemPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return sectionInsets.left
    }
}
