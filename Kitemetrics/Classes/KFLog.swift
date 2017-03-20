//
//  KFLog.swift
//  Pods
//
//  Created by Kitefaster on 2/24/17.
//  Copyright © 2017 Kitefaster, LLC. All rights reserved.
//

import Foundation

class KFLog {
    
    static let debug = true
    
    static func p(_ message: String) {
        if KFLog.debug {
            print(message)
        }
    }
    
    static func forcePrint(_ message: String) {
        print(message)
    }
}
