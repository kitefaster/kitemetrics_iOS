//
//  KMUserDefaults.swift
//  Kitemetrics
//
//  Created by Kitemetrics on 10/27/16.
//  Copyright © 2021 Kitemetrics. All rights reserved.
//

import Foundation

class KMUserDefaults {
    
    class func setApplicationId(_ kitemetricsApplicationId: Int) {
        UserDefaults.standard.set(kitemetricsApplicationId, forKey: "com.kitemetrics.applicationId")
    }
    
    class func applicationId() -> Int {
        return UserDefaults.standard.integer(forKey: "com.kitemetrics.applicationId")
    }
    
    class func setDeviceId(_ kitemetricsDeviceId: Int) {
        UserDefaults.standard.set(kitemetricsDeviceId, forKey: "com.kitemetrics.deviceId")
    }
    
    class func deviceId() -> Int {
        return UserDefaults.standard.integer(forKey: "com.kitemetrics.deviceId")
    }
    
    class func setVersionId(kitemetricsVersionId: Int?) {
        UserDefaults.standard.set(kitemetricsVersionId, forKey: "com.kitemetrics.versionId")
    }
    
    class func versionId() -> Int {
        return UserDefaults.standard.integer(forKey: "com.kitemetrics.versionId")
    }
    
    class func setLastVersion(_ lastVersion: [String: String]) {
        UserDefaults.standard.set(lastVersion, forKey: "com.kitemetrics.lastVersion")
    }
    
    class func lastVersion() -> [String: String]? {
        return UserDefaults.standard.dictionary(forKey: "com.kitemetrics.lastVersion") as? [String: String]
    }
    
    class func setLaunchTime(_ datetime: Date) {
        UserDefaults.standard.set(datetime, forKey: "com.kitemetrics.launchTime")
    }
    
    class func launchTime() -> Date? {
        return UserDefaults.standard.value(forKey: "com.kitemetrics.launchTime") as? Date
    }

    class func setCloseTime(_ datetime: Date) {
        UserDefaults.standard.set(datetime, forKey: "com.kitemetrics.closeTime")
    }
    
    class func closeTime() -> Date? {
        return UserDefaults.standard.value(forKey: "com.kitemetrics.closeTime") as? Date
    }
    
    class func setLastAttemptToSendErrorQueue(_ datetime: Date) {
        UserDefaults.standard.set(datetime, forKey: "com.kitemetrics.lastAttemptToSendErrorQueue")
    }
    
    class func lastAttemptToSendErrorQueue() -> Date? {
        return UserDefaults.standard.value(forKey: "com.kitemetrics.lastAttemptToSendErrorQueue") as? Date
    }
    
    class func setNeedsSearchAdsAttribution(_ needsAttribution: Bool) {
        UserDefaults.standard.set(needsAttribution, forKey: "com.kitemetrics.needsSearchAdsAttribution")
    }
    
    class func needsSearchAdsAttribution() -> Bool {
        return UserDefaults.standard.bool(forKey: "com.kitemetrics.needsSearchAdsAttribution")
    }
    
    class func setInstallDate(date: Date) {
        UserDefaults.standard.set(date, forKey: "com.kitemetrics.installDate")
    }
    
    class func installDate() -> Date {
        let value = UserDefaults.standard.value(forKey: "com.kitemetrics.installDate")
        if value != nil {
            let val = value as? Date
            if val != nil {
                return val!
            }
        }
        
        //Install date not yet set.  Set it now.
        let today = Date()
        setInstallDate(date: today)
        return today
    }
    
    class func incrementAttributionRequestAttemptNumber() -> Int {
        var attemptNumber = attributionRequestAttemptNumber()
        attemptNumber = attemptNumber + 1
        UserDefaults.standard.set(attemptNumber, forKey: "com.kitemetrics.attributionRequestAttemptNumber")
        return attemptNumber
    }
    
    class func attributionRequestAttemptNumber() -> Int {
        return UserDefaults.standard.integer(forKey: "com.kitemetrics.attributionRequestAttemptNumber")
    }
    
    class func setAttribution(_ attribution: [String : NSObject]) {
        UserDefaults.standard.set(attribution, forKey: "com.kitemetrics.attribution")
        KMUserDefaults.setAttributionDate()
        KMUserDefaults.setAttributionClientVersionId()
    }
    
    class func attribution() -> [String : NSObject]? {
        return UserDefaults.standard.value(forKey: "com.kitemetrics.attribution") as?  [String : NSObject]
    }
    
    class func setAttributionDate() {
        UserDefaults.standard.set(Date(), forKey: "com.kitemetrics.attributionDate")
    }
    
    class func attributionDate() -> Date? {
        return UserDefaults.standard.value(forKey: "com.kitemetrics.attributionDate") as? Date
    }
    
    class func setAttributionClientVersionId() {
        if KMUserDefaults.attributionClientVersionId() == 0 {
            let versionId = KMUserDefaults.versionId()
            if versionId > 0 {
                UserDefaults.standard.set(versionId, forKey: "com.kitemetrics.attributionClientVersionId")
            }
        }
    }
    
    class func attributionClientVersionId() -> Int {
        return UserDefaults.standard.integer(forKey: "com.kitemetrics.attributionClientVersionId")
    }
    
    class func setAttributionToken(_ attributionTokenString: String) {
        UserDefaults.standard.set(attributionTokenString, forKey: "com.kitemetrics.attributionToken")
    }
    
    // The Attribution Token when ATTrackingManager.AuthorizationStatus is in any status
    class func attributionToken() -> String? {
        return UserDefaults.standard.value(forKey: "com.kitemetrics.attributionToken") as? String
    }
    
    class func setAttributionTokenWithAuthorization(_ attributionTokenString: String) {
        UserDefaults.standard.set(attributionTokenString, forKey: "com.kitemetrics.attributionTokenWithAuthorization")
    }
    
    // The Attribution Token when ATTrackingManager.AuthorizationStatus == .authorized
    class func attributionTokenWithAuthorization() -> String? {
        return UserDefaults.standard.value(forKey: "com.kitemetrics.attributionTokenWithAuthorization") as? String
    }
    
    class func setAttributionTokenTimestamp() {
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "com.kitemetrics.attributionTokenTimestamp")
    }
    
    class func attributionTokenTimestamp() -> TimeInterval? {
        return UserDefaults.standard.value(forKey: "com.kitemetrics.attributionTokenTimestamp") as? TimeInterval
    }

}
