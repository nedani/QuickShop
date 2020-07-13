//
//  Reachability.swift
//  QuickShop
//
//  Created by neda niazalizadeh on 2020-06-07.
//  Copyright © 2020 neda niazalizadeh. All rights reserved.
//

import Foundation
import SystemConfiguration

//check for internet Connection
public class Reachability {
    
    class func HasConnection() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRoutReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1, {
                zeroSockAddress in
                
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            })
        })
        
        var flags : SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        
        if SCNetworkReachabilityGetFlags(defaultRoutReachability!, &flags) == false {
            return false
        }
        
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        
        let needConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return (isReachable && !needConnection)
    }
}





