//
//  category.swift
//  QuickShop
//
//  Created by neda niazalizadeh on 2020-06-02.
//  Copyright © 2020 neda niazalizadeh. All rights reserved.
//

import Foundation
import UIKit

class Category {
    
    var id : String
    var name : String
    var imageName : String?
    var image: UIImage?
    
    init(name: String, imageName: String) {
        id = ""
        self.name = name
        self.imageName = imageName
        image = UIImage(named: imageName)
    }
    
    init(dictionary : NSDictionary) {
        
        id = dictionary[Constants.K.id] as! String
        name = dictionary[Constants.K.name] as! String
        image = UIImage(named: dictionary[Constants.K.imageName] as? String ?? "")
    }
    
}

// MARK:- fireBase methods

// to save category in firebase
func saveCategoryToFirebase(category : Category) {
    
    let id = UUID().uuidString
    category.id = id
    
    FirebaseReference(.Category).document(id).setData(categoryDictonaryFrom(category) as! [String:Any])
}

//to download data from firebase
// retrives all the categories from firebase
func downloadCategoriesFromFirebase(completion: @escaping (_ categoryArray: [Category])-> Void) {
    
    var categoryArray: [Category] = []
    
    FirebaseReference(.Category).getDocuments { (snapshot, error) in
        guard let snapshot = snapshot else {
            completion(categoryArray)
            return
        }
        if !snapshot.isEmpty {
            for categoryDict in snapshot.documents {
                categoryArray.append(Category(dictionary: categoryDict.data() as NSDictionary))
            }
        }
        
        completion(categoryArray)
    }
    
}
// MARK:- Helpers methods

//to convert category to dictionary
func categoryDictonaryFrom(_ category : Category) -> NSDictionary {
    
    return NSDictionary(objects: [category.id,category.name,category.imageName], forKeys: [Constants.K.id as NSCopying, Constants.K.name as NSCopying, Constants.K.imageName as NSCopying])
}



//this function called once to save categories in firebase
func createCategorySet() {
    
    let womenClothing = Category(name: "Women's Clothing & Accessories", imageName: "womenCloth")
    let footWear = Category(name: "Footwear", imageName: "footWaer")
    let electronics = Category(name: "Electronics", imageName: "electronics")
    let menClothing = Category(name: "Men's Clothing & Accessories" , imageName: "menCloth")
    let health = Category(name: "Health & Beauty", imageName: "health")
    let baby = Category(name: "Baby Stuff", imageName: "baby")
    let home = Category(name: "Home & Kitchen", imageName: "home")
    let car = Category(name: "Automobiles & Motorcyles", imageName: "car")
    let luggage = Category(name: "Luggage & bags", imageName: "luggage")
    let jewelery = Category(name: "Jewelery", imageName: "jewelery")
    let hobby =  Category(name: "Hobby, Sport, Traveling", imageName: "hobby")
    let pet = Category(name: "Pet products", imageName: "pet")
    let industry = Category(name: "Industry & Business", imageName: "industry")
    let garden = Category(name: "Garden supplies", imageName: "garden")
    let camera = Category(name: "Cameras & Optics", imageName: "camera")
    
    let arrayOfCategory = [womenClothing,footWear,electronics,menClothing,health,baby,home,car,luggage,jewelery,hobby,pet,industry,garden,camera]
    
    for category in arrayOfCategory {
        saveCategoryToFirebase(category: category)
    }
}

