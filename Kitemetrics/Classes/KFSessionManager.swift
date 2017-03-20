//
//  KFSession.swift
//  Pods
//
//  Created by kitefaster on 10/27/16.
//  Copyright © 2017 Kitefaster, LLC. All rights reserved.
//

import Foundation

protocol KFSessionManagerDelegate {
    func sessionReadyToPost(launchTime: Date, closeTime: Date)
}

class KFSessionManager {
    
    var delegate: KFSessionManagerDelegate?
    
    func open() {
        let now = Date()
        let lastLaunchTime = KFUserDefaults.launchTime()
        let lastCloseTime = KFUserDefaults.closeTime()
        
        if lastLaunchTime == nil && lastCloseTime == nil {
            //The very first launch of the app.  Start the session.
            KFUserDefaults.setLaunchTime(now)
            //Set the close time to now also, just incase the app crashes or terminates early.
            KFUserDefaults.setCloseTime(now)
            return
        }
        
        
        if fabs(lastCloseTime!.timeIntervalSinceNow) < 30 {
            //If last close time is less than 30 seconds, continue as the same session
            KFUserDefaults.setCloseTime(now)
            //Leave start time alone, since it is a continuation
            return
        }
        
        //Post the last session
        if lastLaunchTime != nil && lastCloseTime != nil{
            self.delegate?.sessionReadyToPost(launchTime: lastLaunchTime!, closeTime: lastCloseTime!)
        } else {
            //Somehow one of the values is still null.  Log error.
            KFError.logErrorMessage("One of the session values is null")
        }
        
        //Start the new session
        KFUserDefaults.setLaunchTime(now)
        KFUserDefaults.setCloseTime(now)
    }
    
}
