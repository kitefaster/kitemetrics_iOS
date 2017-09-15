//
//  KFHelper.swift
//  Pods
//
//  Created by Kitefaster on 10/24/16.
//  Copyright © 2017 Kitefaster, LLC. All rights reserved.
//

import Foundation
import StoreKit

enum KFPurchaseFunnel: Int {
    case view = 1
    case addToCart = 2
    case purchase = 3
    case promotedInAppPurchase = 4
}

enum KFInstallType: Int {
    case unknown = 0
    case newInstall = 1
    case reinstall = 2
    case appVersionUpdate = 3
    case userChange = 4
    case osChange = 5
}

@objc
public enum KFPurchaseType: Int {
    case appleInAppUnknown = 1
    case appleInAppConsumable = 2
    case appleInAppNonConsumable = 3
    case appleInAppAutoRenewableSubscription = 4
    case appleInAppNonRenewingSubscription = 5
    case applePaidApp = 6
}

class KFHelper {
    
    class func applicationDict() -> [String: String] {
        var dict = [String: String]()
        dict["bundleDisplayName"] = KFDevice.appBundleDisplayName()
        dict["bundleName"] = KFDevice.appBundleName()
        dict["bundleId"] = KFDevice.appBundleId()
        return dict
    }
    
    class func deviceDict() -> [String: String] {
        var dict = [String: String]()
        dict["deviceIdForVendor"] = KFDevice.identifierForVendor()
        var deviceType = KFDevice.deviceType()
        deviceType = deviceType.replacingOccurrences(of: "\0", with: "")
        dict["advertisingIdentifier"] = KFDevice.advertisingIdentifier()
        dict["deviceType"] = deviceType
        return dict
    }
    
    class func versionDict() -> [String: String] {
        var dict = [String: String]()
        dict["userIdentifier"] = Kitemetrics.shared.userIdentifier
        dict["appVersion"] = KFDevice.appVersion()
        dict["appBuild"] = KFDevice.appBuildVersion()
        dict["osVersion"] = KFDevice.iosVersion()
        dict["osCountry"] = KFDevice.regionCode()
        dict["osLanguage"] = KFDevice.preferredLanguage()
        
        //applicationId - added in Kitemetrics post method
        //deviceId - added in Kitemetrics post method
        //installType - added in Kitemetrics post method
        //timestamp - added in Kitemetrics post method
        return dict
    }
    
    class func sessionDict(launchTime: Date, closeTime: Date) -> [String: Any] {
        var dict = [String: Any]()
        if let versionId = KFUserDefaults.versionId() {
            if versionId > 0 {
                dict["versionId"] = versionId
            }
        }
        
        dict["start"] = launchTime.timeIntervalSince1970
        dict["end"] = closeTime.timeIntervalSince1970
        
        return dict
    }
    
    class func eventDict(_ event: String) -> [String: Any] {
        var dict = [String: Any]()
        dict["timestamp"] = Kitemetrics.shared.timeIntervalSince1970()
        dict["event"] = event.truncate(255)
        
        if let versionId = KFUserDefaults.versionId() {
            if versionId > 0 {
                dict["versionId"] = versionId
            }
        }
        return dict
    }
    
    class func eventSignUpDict(method: String, userIdentifier: String) -> [String: Any] {
        var dict = [String: Any]()
        dict["timestamp"] = Kitemetrics.shared.timeIntervalSince1970()
        dict["method"] = method.truncate(255)
        dict["userIdentifier"] = userIdentifier.truncate(255)
        
        if let versionId = KFUserDefaults.versionId() {
            if versionId > 0 {
                dict["versionId"] = versionId
            }
        }
        return dict
    }
    
    class func eventInviteDict(method: String, code: String?) -> [String: Any] {
        var dict = [String: Any]()
        dict["timestamp"] = Kitemetrics.shared.timeIntervalSince1970()
        dict["method"] = method.truncate(255)
        if code != nil {
            dict["code"] = code!.truncate(255)
        }
        
        if let versionId = KFUserDefaults.versionId() {
            if versionId > 0 {
                dict["versionId"] = versionId
            }
        }
        return dict
    }
    
    class func eventRedeemInviteDict(code: String) -> [String: Any] {
        var dict = [String: Any]()
        dict["timestamp"] = Kitemetrics.shared.timeIntervalSince1970()
        dict["code"] = code.truncate(255)
        
        if let versionId = KFUserDefaults.versionId() {
            if versionId > 0 {
                dict["versionId"] = versionId
            }
        }
        return dict
    }
    
    class func errorDict(_ error: String, isInternal: Bool) -> [String: Any] {
        var dict = [String: Any]()
        dict["timestamp"] = Kitemetrics.shared.timeIntervalSince1970()
        dict["error"] = error.truncate(1000)
        dict["isInternal"] = isInternal
        
        if let versionId = KFUserDefaults.versionId() {
            if versionId > 0 {
                dict["versionId"] = versionId
            }
        }
        return dict
    }
    
    class func purchaseDict(_ product: SKProduct, quantity: Int, funnel: KFPurchaseFunnel, purchaseType: KFPurchaseType?) -> [String: Any] {
        var dict = [String: Any]()
        dict["timestamp"] = Kitemetrics.shared.timeIntervalSince1970()
        dict["price"] = product.price.floatValue
        dict["currencyCode"] = product.priceLocale.currencyCode
        dict["productIdentifier"] = product.productIdentifier
        dict["quantity"] = quantity
        dict["funnel"] = funnel.rawValue
        if product.isDownloadable == true {
            dict["purchaseTypeValue"] = KFPurchaseType.appleInAppNonConsumable.rawValue
        } else if purchaseType == nil {
            dict["purchaseTypeValue"] = KFPurchaseType.appleInAppUnknown.rawValue
        } else {
             dict["purchaseTypeValue"] = purchaseType?.rawValue
        }
        
        if let versionId = KFUserDefaults.versionId() {
            if versionId > 0 {
                dict["versionId"] = versionId
            }
        }
        return dict
    }
    
    class func applicationJson() -> Data? {
        return jsonFromDictionary(applicationDict())
    }
    
    class func deviceJson() -> Data? {
        return jsonFromDictionary(deviceDict())
    }
    
    class func sessionJson(launchTime: Date, closeTime: Date) -> Data? {
        return jsonFromDictionary(sessionDict(launchTime: launchTime, closeTime: closeTime))
    }
    
    class func eventJson(_ event: String) -> Data? {
        return jsonFromDictionary(eventDict(event))
    }
    
    class func eventSignUpJson(method: String, userIdentifier: String) -> Data? {
        return jsonFromDictionary(eventSignUpDict(method: method, userIdentifier: userIdentifier))
    }
    
    class func eventInviteJson(method: String, code: String?) -> Data? {
        return jsonFromDictionary(eventInviteDict(method: method, code: code))
    }
    
    class func eventRedeemInviteJson(code: String) -> Data? {
        return jsonFromDictionary(eventRedeemInviteDict(code: code))
    }
    
    class func errorJson(_ error: String, isInternal: Bool) -> Data? {
        return jsonFromDictionary(errorDict(error, isInternal: isInternal), logErrors: false)
    }
    
    class func purchaseJson(_ product: SKProduct, quantity: Int, funnel: KFPurchaseFunnel, purchaseType: KFPurchaseType?)-> Data? {
        return jsonFromDictionary(purchaseDict(product, quantity: quantity, funnel: funnel, purchaseType: purchaseType))
    }
    
    class func jsonFromDictionary(_ dictionary: [AnyHashable:Any], logErrors: Bool = true) -> Data? {
        do {
            if KFLog.debug {
                print(dictionary)
            }
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: JSONSerialization.WritingOptions())
            return jsonData
        } catch {
            if logErrors {
                KFError.logError(error)
            } else {
                KFError.printError(error.localizedDescription)
            }
        }
        return nil
    }
    
    class func dictionaryFromJson(_ json: Data) -> [AnyHashable:Any]? {
        do {
            guard let dictionary = try JSONSerialization.jsonObject(with: json, options: JSONSerialization.ReadingOptions()) as? [AnyHashable : Any] else {
                return nil
            }
            return dictionary
        } catch {
            KFError.logError(error)
        }

        return nil
    }
    
}
