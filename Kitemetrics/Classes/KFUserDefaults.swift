//
//  KFUserDefaults.swift
//  Pods
//
//  Created by Kitefaster on 10/27/16.
//  Copyright © 2017 Kitefaster, LLC. All rights reserved.
//

import Foundation

class KFUserDefaults {
    
    class func setApplicationId(kitemetricsApplicationId: Int) {
        UserDefaults.standard.setValue(kitemetricsApplicationId, forKey: "com.kitemetrics.applicationId")
    }
    
    class func applicationId() -> Int? {
        return UserDefaults.standard.integer(forKey: "com.kitemetrics.applicationId")
    }
    
    class func setDeviceId(kitemetricsDeviceId: Int) {
        UserDefaults.standard.setValue(kitemetricsDeviceId, forKey: "com.kitemetrics.deviceId")
    }
    
    class func deviceId() -> Int? {
        return UserDefaults.standard.integer(forKey: "com.kitemetrics.deviceId")
    }
    
    class func setVersionId(kitemetricsVersionId: Int?) {
        UserDefaults.standard.setValue(kitemetricsVersionId, forKey: "com.kitemetrics.versionId")
    }
    
    class func versionId() -> Int? {
        return UserDefaults.standard.integer(forKey: "com.kitemetrics.versionId")
    }
    
    class func setLastVersion(_ lastVersion: [String: String]) {
        UserDefaults.standard.setValue(lastVersion, forKey: "com.kitemetrics.lastVersion")
    }
    
    class func lastVersion() -> [String: String]? {
        return UserDefaults.standard.dictionary(forKey: "com.kitemetrics.lastVersion") as? [String: String]
    }
    
    class func setLaunchTime(_ datetime: Date) {
        UserDefaults.standard.setValue(datetime, forKey: "com.kitemetrics.launchTime")
    }
    
    class func launchTime() -> Date? {
        return UserDefaults.standard.value(forKey: "com.kitemetrics.launchTime") as? Date
    }

    class func setCloseTime(_ datetime: Date) {
        UserDefaults.standard.setValue(datetime, forKey: "com.kitemetrics.closeTime")
    }
    
    class func closeTime() -> Date? {
        return UserDefaults.standard.value(forKey: "com.kitemetrics.closeTime") as? Date
    }
    
    class func setLastAttemptToSendErrorQueue(_ datetime: Date) {
        UserDefaults.standard.setValue(datetime, forKey: "com.kitemetrics.lastAttemptToSendErrorQueue")
    }
    
    class func lastAttemptToSendErrorQueue() -> Date? {
        return UserDefaults.standard.value(forKey: "com.kitemetrics.lastAttemptToSendErrorQueue") as? Date
    }
    
    class func setNeedsSearchAdsAttribution(_ needsAttribution: Bool) {
        UserDefaults.standard.setValue(needsAttribution, forKey: "com.kitemetrics.needsSearchAdsAttribution")
    }
    
    class func needsSearchAdsAttribution() -> Bool {
        return UserDefaults.standard.bool(forKey: "com.kitemetrics.needsSearchAdsAttribution")
    }

}
