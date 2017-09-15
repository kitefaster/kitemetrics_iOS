//
//  KFUtil.swift
//  Pods
//
//  Created by mcl on 9/15/17.
//
//

import Foundation


class KFUtil {
    
    class func is32bit() -> Bool {
        return MemoryLayout<Int>.size == MemoryLayout<Int32>.size
    }
    
    class func is64bit() -> Bool {
        return MemoryLayout<Int>.size == MemoryLayout<Int64>.size
    }
    
}
