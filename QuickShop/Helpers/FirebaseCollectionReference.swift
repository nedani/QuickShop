//
//  FirebaseCollectionReference.swift
//  QuickShop
//
//  Created by neda niazalizadeh on 2020-06-02.
//  Copyright © 2020 neda niazalizadeh. All rights reserved.
//

import Foundation
import FirebaseFirestore

//To link Xcode to Firebase
enum FCollectionReference: String {
    
    case User
    case Category
    case Item
    case Basket
}

func FirebaseReference (_ collectionReference: FCollectionReference) -> CollectionReference {
    
    return Firestore.firestore().collection(collectionReference.rawValue)
}
