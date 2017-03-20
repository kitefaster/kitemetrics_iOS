//
//  KFError.swift
//  Pods
//
//  Created by Kitefaster on 11/1/16.
//  Copyright © 2017 Kitefaster, LLC. All rights reserved.
//

import Foundation

class KFError {
    
    class func logAsNSError(_ error: Error) {
        let nsError = error as NSError
        logErrorMessage(nsError.description)
    }
    
    class func logError(_ error: Error, sendToServer: Bool = true) {
        if sendToServer {
            KFError.logAsNSError(error)
        } else {
            KFError.logErrorMessage(error.localizedDescription, sendToServer: sendToServer)
        }
    }
    
    class func logErrorMessage(_ errorMessage: String, sendToServer: Bool = true) {
        KFLog.p("========== Kitemetrics ERROR: " + errorMessage)
        if sendToServer {
            Kitemetrics.shared.postError(errorMessage, isInternal: true)
        }
    }
    
    class func printError(_ errorMessage: String) {
        KFLog.forcePrint("========== Kitemetrics ERROR: " + errorMessage)
    }
    
    
    
}
