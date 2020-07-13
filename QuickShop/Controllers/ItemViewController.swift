//
//  ItemViewController.swift
//  QuickShop
//
//  Created by neda niazalizadeh on 2020-06-12.
//  Copyright © 2020 neda niazalizadeh. All rights reserved.
//

import UIKit
import JGProgressHUD

class ItemViewController: UIViewController {
    
    @IBOutlet weak var imageCollection: UICollectionView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    var item : Item!
    var itemImages : [UIImage] = []
    let hud = JGProgressHUD(style: .dark)
    
    private let itemPerRow : CGFloat = 1
    private let sectionInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    private let cellHeight : CGFloat = 196.0
    
    
    //MARK:- lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        downloadPics()
        
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(self.backAction))]
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "addToBasket"), style: .plain, target: self, action: #selector(self.addToBasketPressed))
        
        
    }
    
    //MARK:- setup UserInterface
    
    private func setupUI() {
        
        if item != nil {
            self.title = item.name
            nameLabel.text = item.name
            priceLabel.text = converToCurrency(item.price)
            descriptionTextView.text = item.description
        }
    }
    
    //MARK:- download images
    
    private func downloadPics() {
        
        if item != nil && item.imageLink != nil {
            downloadImages(imageUrls: item.imageLink) { (allImages) in
                if allImages.count > 0 {
                    self.itemImages = allImages as! [UIImage]
                    self.imageCollection.reloadData()
                }
            }
        }
    }
    
    @objc func backAction() {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func addToBasketPressed() {
        
        if MUser.currentUser() != nil {
            downloadBasketFromFirestore(MUser.currentId()) { (basket) in
                
                if basket == nil {
                    self.createNewBasket()
                }
                else {
                    basket!.itemIds.append(self.item.id)
                    self.updateBasket(basket: basket!, withValues: [Constants.K.basket.itemIds: basket!.itemIds])
                }
            }
        } else {
            showLoginView()
        }
    }
    
    //add to basket
    private func createNewBasket() {
        
        let newBasket = Basket()
        newBasket.id = UUID().uuidString
        newBasket.ownerId = MUser.currentId()
        newBasket.itemIds = [self.item.id]
        saveBasketToFirestore(newBasket)
        self.hud.textLabel.text = "Added to basket!"
        self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        self.hud.show(in: self.view)
        self.hud.dismiss(afterDelay: 2.0)
    }
    
    private func updateBasket(basket: Basket, withValues: [String : Any]) {
        
        updateBasketInFirestore(basket, withValues: withValues) { (error) in
            
            if error != nil {
                self.hud.textLabel.text = "Error: \(error!.localizedDescription)"
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
                
                print("error updation basket", error!.localizedDescription)
                
            }
            else {
                self.hud.textLabel.text = "Added to basket!"
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            }
        }
    }
    
    //MARK:- show login view
    private func showLoginView() {
        
        let loginView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "loginView")
        
        self.present(loginView, animated: true, completion: nil)
    }
}
//MARK:- CollectionView Methods
extension ItemViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return itemImages.count == 0 ? 1 : itemImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageCollectionViewCell
        
        if itemImages.count > 0 {
            cell.showImages(itemImage: itemImages[indexPath.row])
        }
        
        return cell
    }
}

// MARK:- collectionViewDelegate
extension ItemViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let availableSpace = collectionView.frame.width - sectionInsets.left
        
        return CGSize(width: availableSpace, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return sectionInsets.left
    }
}


