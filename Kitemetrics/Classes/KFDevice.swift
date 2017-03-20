//
//  KFDevice.swift
//  Pods
//
//  Created by Kitefaster on 10/21/16.
//  Copyright © 2017 Kitefaster, LLC. All rights reserved.
//

import Foundation
import AdSupport


public class KFDevice {
    
    //The build-version-number string for the bundle
    public class func appBuildVersion() -> String {
        return stringValueFromInfoDict(kCFBundleVersionKey as String)
    }
    
    // The release-version-number string for the bundle.
    public class func appVersion() -> String {
        return stringValueFromInfoDict("CFBundleShortVersionString")
    }
    
    //The user-visible name of the bundle; used by Siri and visible on the Home screen in iOS.
    public class func appBundleDisplayName() -> String {
        return stringValueFromInfoDict("CFBundleDisplayName")
    }
    
    //The human-readable name of the bundle.  This key is often found in the InfoPlist.strings since it is usually localized.
    public class func appBundleName() -> String {
        return stringValueFromInfoDict(kCFBundleNameKey as String)
    }
    
    //An identifier string that specifies the app type of the bundle. The string should be in reverse DNS format.
    public class func appBundleId() -> String {
        return stringValueFromInfoDict(kCFBundleIdentifierKey as String)
    }
    
    public class func advertisingIdentifier() -> String {
        if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
            return ASIdentifierManager.shared().advertisingIdentifier.uuidString
        } else {
            return ""
        }
    }
    
    class func stringValueFromInfoDict(_ key: String) -> String {
        let dict = NSDictionary(dictionary: Bundle.main.infoDictionary!)
        guard let bundleObject = dict.object(forKey: key) else {
            return ""
        }
        
        guard let string = bundleObject as? String else {
            return ""
        }
        return string
    }
    
    //e.g. Version 10.0 (Build 14A345)
    public class func iosVersion() -> String {
        return ProcessInfo.processInfo.operatingSystemVersionString
    }

    
    public class func deviceType() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        guard let deviceType = NSString(bytes: &systemInfo.machine, length: Int(_SYS_NAMELEN), encoding: String.Encoding.ascii.rawValue) as? String else {
            return KFDevice.model()
        }
        return deviceType
    }
    
    //e.g. iPhone
    class func model() -> String {
        return UIDevice.current.model
    }
    
    //e.g. en
    public class func preferredLanguage() -> String {
        if Locale.preferredLanguages.count > 0 {
            return Locale.preferredLanguages[0]
        }
        return ""
    }
    
    //e.g. US
    public class func regionCode() -> String {
        guard let regionCode = Locale.current.regionCode else {
            return ""
        }
        return regionCode
    }
    
    //e.g. iOS
    class func systemName() -> String {
        return UIDevice.current.systemName
    }
    
    //e.g. 10.0
    class func systemVersion() -> String {
        return UIDevice.current.systemVersion
    }
    
    //e.g. 744643BA-0BB4-469F-BD23-7BC5AF3A708E
    public class func identifierForVendor() -> String {
        guard let uuid = UIDevice.current.identifierForVendor else {
            return ""
        }
        return uuid.uuidString
    }
    
}
