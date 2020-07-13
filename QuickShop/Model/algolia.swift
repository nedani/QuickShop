//
//  algolia.swift
//  QuickShop
//
//  Created by neda niazalizadeh on 2020-07-01.
//  Copyright © 2020 neda niazalizadeh. All rights reserved.
//

import Foundation
import InstantSearchClient

class AlgoliaService  {
    
    static let shared = AlgoliaService()
    
    let client  = Client(appID: Constants.app_id , apiKey: Constants.admin_key)
    let index = Client(appID: Constants.app_id , apiKey: Constants.admin_key).index(withName: "name")

    private init () {}
    
}
