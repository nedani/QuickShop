//
//  AddItemViewController.swift
//  QuickShop
//
//  Created by neda niazalizadeh on 2020-06-07.
//  Copyright © 2020 neda niazalizadeh. All rights reserved.
//

import UIKit
import Gallery
import JGProgressHUD
import NVActivityIndicatorView

class AddItemViewController: UIViewController,UITextViewDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var category: Category!
    var gallery: GalleryController!
    var hud = JGProgressHUD(style: .dark)
    var activityIndicator : NVActivityIndicatorView?
    
    var itemImages : [UIImage?] = []
    
    //MARK:- lifeCycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionTextView.text = "Description"
        descriptionTextView.textColor = UIColor.gray
        descriptionTextView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 30, y: self.view.frame.height / 2 - 30, width: 60, height: 60), type: .ballSpinFadeLoader, color: UIColor.init(named: "color-blue"), padding: nil)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if descriptionTextView.text == "Description" {
            
            descriptionTextView.text = ""
            descriptionTextView.textColor = UIColor.black
        }
        
    }
    //MARK:- pressedButtons
    @IBAction func cameraPressed(_ sender: UIButton) {
        
        showItemGallery()
    }
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        
        dismissKeyboard()
        
        if (titleTextField.text != "" && priceTextField.text != "" && descriptionTextView.text != "") {
            
            saveToFirebase()
        }
        else {
            hud.textLabel.text = "All Fields are required!"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 3.0)
            
        }
    }
    
    @IBAction func viewClicked(_ sender: UITapGestureRecognizer) {
        
        dismissKeyboard()
    }
    
    //MARK:- helper methods
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showItemGallery() {
        
        self.gallery = GalleryController()
        self.gallery.delegate = self
        
        Config.tabsToShow = [.cameraTab,.imageTab]
        Config.Camera.imageLimit = 6
        
        self.present(self.gallery, animated: true, completion: nil)
    }
    
    //MARK:- save item
    
    func saveToFirebase() {
        
        showLoadingIndicator()
        
        let item = Item()
        item.id = UUID().uuidString
        item.name = titleTextField.text!
        item.description = descriptionTextView.text
        item.categoryId = category.id
        item.price = Double(priceTextField.text!)
        
        
        if itemImages.count > 0 {
            
            uploadImages(images: itemImages, itemId: item.id) { (ArrayLinkImages) in
                
                item.imageLink = ArrayLinkImages
                print("Saved Links: \(ArrayLinkImages)")
                
                saveItemToFirebase(item: item)
                saveItemToAlgolia(item: item)
                self.hideLoadingIndicator()
                self.popTheView()
            }
            
        } else {
            saveItemToFirebase(item: item)
            saveItemToAlgolia(item: item)
            popTheView()
        }
    }
    
    func popTheView() {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Activity Indicator
    private func showLoadingIndicator() {
        
        if activityIndicator != nil {
            self.view.addSubview(activityIndicator!)
            activityIndicator!.startAnimating()
        }
    }
    
    private func hideLoadingIndicator() {
        
        if activityIndicator != nil {
            activityIndicator!.removeFromSuperview()
            activityIndicator!.stopAnimating()
        }
    }
}

//MARK:- GalleryControllerDeletgates
extension AddItemViewController: GalleryControllerDelegate {
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        
        if images.count > 0 {
            Image.resolve(images: images) { (resolvedImages) in
                self.itemImages = resolvedImages
            }
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}
