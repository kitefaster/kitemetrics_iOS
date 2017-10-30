//
//  KFString.swift
//  Pods
//
//  Created by Kitefaster on 11/2/16.
//  Copyright © 2017 Kitefaster, LLC. All rights reserved.
//

import Foundation


extension String {
    
    func truncate(_ length: Int) -> String {
        if self.characters.count > length {
            let index = self.index(self.startIndex, offsetBy: length)
            let newString = String(self[...index])
            return newString
        }
        
        return self
    }
    
}
