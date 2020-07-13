//
//  Basket.swift
//  QuickShop
//
//  Created by neda niazalizadeh on 2020-06-12.
//  Copyright © 2020 neda niazalizadeh. All rights reserved.
//

import Foundation

class Basket {
    
    var id: String!
    var ownerId: String!
    var itemIds: [String]!
    
    init() {
        
    }
    
    init(dictionary: NSDictionary) {
        
        id = dictionary[Constants.K.id] as? String
        ownerId = dictionary[Constants.K.basket.ownerId] as? String
        itemIds = dictionary[Constants.K.basket.itemIds] as? [String]
        
    }
}

//MARK:- Download Items from firebase
func downloadBasketFromFirestore(_ ownerId: String, completion: @escaping(_ basket: Basket?)-> Void) {
    
    FirebaseReference(.Basket).whereField(Constants.K.basket.ownerId, isEqualTo: ownerId).getDocuments { (snapshot,error) in
        
        guard let snapshot = snapshot else {
            
            completion(nil)
            return
        }
        if !snapshot.isEmpty && snapshot.documents.count > 0 {
            let basket = Basket(dictionary: snapshot.documents.first!.data() as NSDictionary)
            completion(basket)
        }
        else {
            completion(nil)
        }
    }
    
}

//MARK:- update Basket
func updateBasketInFirestore(_ basket: Basket, withValues: [String: Any], completion: @escaping (_ error: Error?)->Void){
    
    FirebaseReference(.Basket).document(basket.id).updateData(withValues) { (error) in
        completion(error)
    }
}

//MARK:- save to firebase
func saveBasketToFirestore(_ basket: Basket) {
    
    FirebaseReference(.Basket).document(basket.id).setData(basketDictonaryFrom(basket) as! [String: Any])
}

//convert basket to dic to store in firebase
func basketDictonaryFrom(_ basket : Basket) -> NSDictionary {
    
    return NSDictionary(objects: [basket.id, basket.ownerId, basket.itemIds], forKeys: [Constants.K.id as NSCopying,Constants.K.basket.ownerId as NSCopying, Constants.K.basket.itemIds as NSCopying])
}
