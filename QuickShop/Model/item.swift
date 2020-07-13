//
//  item.swift
//  QuickShop
//
//  Created by neda niazalizadeh on 2020-06-05.
//  Copyright © 2020 neda niazalizadeh. All rights reserved.
//

import Foundation
import UIKit
import InstantSearchClient

class Item {
    
    var id: String!
    var categoryId: String!
    var name: String!
    var description: String!
    var price: Double!
    var imageLink: [String]!
    
    init() {
    }
    
    init(dictionary: NSDictionary) {
        
        id = (dictionary[Constants.K.id] as? String)
        categoryId = (dictionary[Constants.K.item.categoryId] as? String)
        name = (dictionary[Constants.K.name] as? String)
        description = (dictionary[Constants.K.item.description] as? String)
        price = (dictionary[Constants.K.item.price] as? Double)
        imageLink = (dictionary[Constants.K.item.imageLink] as? [String])
    }
}

// MARK:- fireBase methods

// to save item in firebase
func saveItemToFirebase(item : Item) {
    
    FirebaseReference(.Item).document(item.id).setData(itemDictonaryFrom(item) as! [String:Any])
}

// MARK:- Helpers methods

//to convert item to dictionary
func itemDictonaryFrom(_ item : Item) -> NSDictionary {
    
    return NSDictionary(objects: [item.id,item.categoryId,item.name,item.description,item.price,item.imageLink], forKeys: [Constants.K.id as NSCopying,Constants.K.item.categoryId as NSCopying, Constants.K.name as NSCopying,Constants.K.item.description as NSCopying, Constants.K.item.price as NSCopying, Constants.K.item.imageLink as NSCopying])
}

//to download data from firebase
// retrives all the items from firebase
func downloadItemsFromFirebase(completion: @escaping (_ itemArray: [Item])-> Void) {
    
    var itemArray: [Item] = []
    
    FirebaseReference(.Item).getDocuments { (snapshot, error) in
        guard let snapshot = snapshot else {
            completion(itemArray)
            return
        }
        if !snapshot.isEmpty {
            for itemDict in snapshot.documents {
                itemArray.append(Item(dictionary: itemDict.data() as NSDictionary))
            }
        }
        completion(itemArray)
    }
    
}

//to download items from firebase for a specific category
func downloadItemFromFirebase(_ withCategoryId: String,completion: @escaping(_ itemArray: [Item])->Void) {
    
    var itemArray : [Item] = []
    FirebaseReference(.Item).whereField(Constants.K.item.categoryId, isEqualTo: withCategoryId).getDocuments { (snapshot, error) in
        
        guard let snapshot = snapshot else {
            completion(itemArray)
            return
        }
        if !snapshot.isEmpty {
            for itemDict in snapshot.documents {
                itemArray.append(Item(dictionary: itemDict.data() as NSDictionary))
            }
        }
        completion(itemArray)
    }
}


func downloadItems(_ withIds: [String], completion: @escaping (_ itemArray:[Item])->Void) {
    
    var count = 0
    var itemArray : [Item] = []
    
    if withIds.count > 0 {
        
        for itemId in withIds {
            
            FirebaseReference(.Item).document(itemId).getDocument{ (snapshot,error) in
                
                guard let snapshot = snapshot else {
                    completion(itemArray)
                    return
                }
                 
                if snapshot.exists
                {
                    itemArray.append(Item(dictionary: snapshot.data()! as NSDictionary))
                    count += 1
                }
                else {
                    completion(itemArray)
                }
                
                if count == withIds.count {
                    
                    completion(itemArray)
                }
            }
        }
    }
    else {
        completion(itemArray)
    }
}

//MARK:- Algolia methods

func saveItemToAlgolia(item: Item) {
    
    let index = AlgoliaService.shared.index
    let itemToSave = itemDictonaryFrom(item) as! [String:Any]
    
    index.addObject(itemToSave, withID: item.id, requestOptions: nil) { (content, error) in
        
        if error != nil {
            print("error saving to algolia", error!.localizedDescription)
            
        }
        else {
            print("added to algolia")
        }
    }
}

func searchAlgolia (searchString : String, completion : @escaping (_ itemArray: [String])->Void) {
    
    let index = AlgoliaService.shared.index
    var resultIds: [String] = []
    
    let query = Query(query: searchString)
    query.attributesToRetrieve = ["name","description"]
    index.search(query) { (content, error) in
        
        if error == nil {
            let cont = content!["hits"] as! [[String:Any]]
            resultIds = []
            
            for result in cont {
                resultIds.append(result["objectID"] as! String)
            }
            completion(resultIds)
        }
        else {
            print("error algolia search", error!.localizedDescription)
            completion(resultIds)
        }
    }
}
