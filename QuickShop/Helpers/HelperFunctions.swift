//
//  HelperFunctions.swift
//  QuickShop
//
//  Created by neda niazalizadeh on 2020-06-12.
//  Copyright © 2020 neda niazalizadeh. All rights reserved.
//

import Foundation


func converToCurrency(_ number: Double)-> String {
    
    let currencyFormatter = NumberFormatter()
    currencyFormatter.usesGroupingSeparator = true
    currencyFormatter.numberStyle = .currency
    currencyFormatter.locale = Locale.current
    
    return currencyFormatter.string(from: NSNumber(value: number))!
    
}
