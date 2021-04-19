//
//  KMSession.swift
//  Kitemetrics
//
//  Created by Kitemetrics on 10/27/16.
//  Copyright © 2021 Kitemetrics. All rights reserved.
//

import Foundation

protocol KMSessionManagerDelegate {
    func sessionReadyToPost(launchTime: Date, closeTime: Date)
}

class KMSessionManager {
    
    var delegate: KMSessionManagerDelegate?
    
    func open() {
        let now = Date()
        let lastLaunchTime = KMUserDefaults.launchTime()
        let lastCloseTime = KMUserDefaults.closeTime()
        
        if lastLaunchTime == nil && lastCloseTime == nil {
            //The very first launch of the app.  Start the session.
            KMUserDefaults.setLaunchTime(now)
            //Set the close time to now also, just incase the app crashes or terminates early.
            KMUserDefaults.setCloseTime(now)
            return
        }
        
        
        if fabs(lastCloseTime!.timeIntervalSinceNow) < 30 {
            //If last close time is less than 30 seconds, continue as the same session
            KMUserDefaults.setCloseTime(now)
            //Leave start time alone, since it is a continuation
            return
        }
        
        //Post the last session
        if lastLaunchTime != nil && lastCloseTime != nil{
            self.delegate?.sessionReadyToPost(launchTime: lastLaunchTime!, closeTime: lastCloseTime!)
        } else {
            //Somehow one of the values is still null.  Log error.
            KMError.logErrorMessage("One of the session values is null")
        }
        
        //Start the new session
        KMUserDefaults.setLaunchTime(now)
        KMUserDefaults.setCloseTime(now)
    }
    
}
