//
//  Constant.swift
//  QuickShop
//
//  Created by neda niazalizadeh on 2020-06-02.
//  Copyright © 2020 neda niazalizadeh. All rights reserved.
//

import Foundation

enum Constants {
    static let app_id = "YOEFR3427V"
    static let search_key = "6b8b9153049d185505a94bd18cab92ad"
    static let admin_key = "1b7cc5bfd90c517964d22a13164e1f67"
    
    struct K {
        static let id = "objectId"
        static let name = "name"
        static let imageName = "imageName"
        
        struct firebase {
            static let userPath = "User"
            static let categoryPath = "Category"
            static let basketPath = "Basket"
            static let itemsPath = "Items"
            static let storagePath = "gs://quickshop-32737.appspot.com"
        }
        
        struct item {
            static let categoryId = "categoryId"
            static let description = "description"
            static let price = "price"
            static let imageLink = "imageLink"
        }
        
        struct basket {
            static let ownerId = "ownerId"
            static let itemIds = "itemIds"
        }
        
        struct user {
            static let email = "email"
            static let firstName = "firstName"
            static let lastName = "lastName"
            static let fullName = "fullName"
            static let currentUser = "currentUser"
            static let fullAddress = "fullAddress"
            static let onBoard = "onBoard"
            static let purchasedItems = "purchasedItems"
        }
        
        struct stripe {
            static let publishableKey = "pk_test_51H06jIHPBCR2NZ0j3A7vIltwp3nYlaVpuPfYOhmYwDvtUx3pT5qoInKnAYI2dNtD6xZnw6Dj6InCwAk48aKrosii00MYlaWIgp"
            static let baseURLString = "https://ios-quickshop.herokuapp.com" //"http://localhost:3000/"//
            static let defaultCurrency = "usd"
            static let defaultDescription = "purchase from QuickShop"
        }
    }
    
}
