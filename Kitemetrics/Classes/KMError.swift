//
//  KMError.swift
//  Kitemetrics
//
//  Created by Kitemetrics on 11/1/16.
//  Copyright © 2021 Kitemetrics. All rights reserved.
//

import Foundation

class KMError {
    
    class func logAsNSError(_ error: Error) {
        let nsError = error as NSError
        logErrorMessage(nsError.description)
    }
    
    class func logError(_ error: Error, sendToServer: Bool = true) {
        if sendToServer {
            KMError.logAsNSError(error)
        } else {
            KMError.logErrorMessage(error.localizedDescription, sendToServer: sendToServer)
        }
    }
    
    class func logErrorMessage(_ errorMessage: String, sendToServer: Bool = true) {
        KMLog.p("========== Kitemetrics ERROR: " + errorMessage)
        if sendToServer {
            Kitemetrics.shared.postError(errorMessage, isInternal: true)
        }
    }
    
    class func printError(_ errorMessage: String) {
        KMLog.forcePrint("========== Kitemetrics ERROR: " + errorMessage)
    }
    
    class func printWarning(_ errorMessage: String) {
        KMLog.forcePrint("========== Kitemetrics WARNING: " + errorMessage)
    }
    
    
}
