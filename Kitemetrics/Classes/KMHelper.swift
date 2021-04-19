//
//  KMHelper.swift
//  Kitemetrics
//
//  Created by Kitemetrics on 10/24/16.
//  Copyright © 2021 Kitemetrics. All rights reserved.
//

import Foundation
import StoreKit

@available(*, deprecated, renamed: "KMPurchaseFunnel")
public enum KFPurchaseFunnel{}
@available(*, deprecated, renamed: "KMInstallType")
enum KFInstallType{}
@available(*, deprecated, renamed: "KMPurchaseType")
public enum KFPurchaseType{}

//See https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/StoreKitGuide/Chapters/Subscriptions.html#//apple_ref/doc/uid/TP40008267-CH7-SW16 for subscription status
@objc
public enum KMPurchaseFunnel: Int {
    case view = 1
    case addToCart = 2
    case purchase = 3
    case promotedInAppPurchase = 4
    case freeTrial = 5
    case cancel = 6                 //Subscription was canceled by Apple customer support.
    case renewal = 7                //Automatic renewal was successful for an expired subscription.
    case interactiveRenewal = 8     //Customer renewed a subscription interactively after it lapsed, either by using your app’s interface or on the App Store in account settings.
    case didChangeRenewalPref = 9   //Customer changed the plan that takes affect at the next subscription renewal. Current active plan is not affected.
}

enum KMInstallType: Int {
    case unknown = 0
    case newInstall = 1
    case reinstall = 2
    case appVersionUpdate = 3
    case userChange = 4
    case osChange = 5
}

@objc
public enum KMPurchaseType: Int {
    case unknown = 1
    case appleInAppConsumable = 2
    case appleInAppNonConsumable = 3
    case appleInAppAutoRenewableSubscription = 4
    case appleInAppNonRenewingSubscription = 5
    case applePaidApp = 6
    case eCommerce = 7
    case appleInAppSubscription = 8
}

class KMHelper {
    
    class func applicationDict() -> [String: String] {
        var dict: [String: String] = [String: String]()
        dict["bundleDisplayName"] = KMDevice.appBundleDisplayName()
        dict["bundleName"] = KMDevice.appBundleName()
        dict["bundleId"] = KMDevice.appBundleId()
        return dict
    }
    
    class func deviceDict() -> [String: String] {
        var dict: [String: String] = [String: String]()
        dict["deviceIdForVendor"] = KMDevice.identifierForVendor()
        dict["advertisingIdentifier"] = KMDevice.advertisingIdentifier()
        
        var deviceType = KMDevice.deviceType()
        deviceType = deviceType.replacingOccurrences(of: "\0", with: "")
        dict["deviceType"] = deviceType
        return dict
    }
    
    class func deviceAttributionTokenDict() -> [String: Any] {
        var dict: [String: Any] = [String: Any]()
        //deviceId - added in Kitemetrics post method
        dict["deviceIdForVendor"] = KMDevice.identifierForVendor()
        dict["advertisingIdentifier"] = KMDevice.advertisingIdentifier()
        var deviceType = KMDevice.deviceType()
        deviceType = deviceType.replacingOccurrences(of: "\0", with: "")
        dict["deviceType"] = deviceType
        
        dict["attributionToken"] = KMUserDefaults.attributionToken()
        if let attributionTokenTimestamp = KMUserDefaults.attributionTokenTimestamp() {
            dict["attributionTokenTimestamp"] = attributionTokenTimestamp
        }
        
        return dict
    }
    
    class func versionDict() -> [String: String] {
        var dict = [String: String]()
        dict["userIdentifier"] = Kitemetrics.shared.userIdentifier
        dict["appVersion"] = KMDevice.appVersion()
        dict["appBuild"] = KMDevice.appBuildVersion()
        dict["osVersion"] = KMDevice.iosVersion()
        dict["osCountry"] = KMDevice.regionCode()
        dict["osLanguage"] = KMDevice.preferredLanguage()
        
        //applicationId - added in Kitemetrics post method
        //deviceId - added in Kitemetrics post method
        //installType - added in Kitemetrics post method
        //timestamp - added in Kitemetrics post method
        return dict
    }
    
    class func sessionDict(launchTime: Date, closeTime: Date) -> [String: Any] {
        var dict = [String: Any]()
        let versionId = KMUserDefaults.versionId()
        if versionId > 0 {
            dict["versionId"] = versionId
        }
        
        dict["start"] = launchTime.timeIntervalSince1970
        dict["end"] = closeTime.timeIntervalSince1970
        
        return dict
    }
    
    class func eventDict(_ event: String) -> [String: Any] {
        var dict = [String: Any]()
        dict["timestamp"] = Date().timeIntervalSince1970
        dict["event"] = event.truncate(255)
        
        let versionId = KMUserDefaults.versionId()
        if versionId > 0 {
            dict["versionId"] = versionId
        }
        return dict
    }
    
    class func eventSignUpDict(method: String, userIdentifier: String) -> [String: Any] {
        var dict = [String: Any]()
        dict["timestamp"] = Date().timeIntervalSince1970
        dict["method"] = method.truncate(255)
        dict["userIdentifier"] = userIdentifier.truncate(255)
        
        let versionId = KMUserDefaults.versionId()
            if versionId > 0 {
                dict["versionId"] = versionId
            }
        return dict
    }
    
    class func eventInviteDict(method: String, code: String?) -> [String: Any] {
        var dict = [String: Any]()
        dict["timestamp"] = Date().timeIntervalSince1970
        dict["method"] = method.truncate(255)
        if code != nil {
            dict["code"] = code!.truncate(255)
        }
        
        let versionId = KMUserDefaults.versionId()
        if versionId > 0 {
            dict["versionId"] = versionId
        }
        return dict
    }
    
    class func eventRedeemInviteDict(code: String) -> [String: Any] {
        var dict = [String: Any]()
        dict["timestamp"] = Date().timeIntervalSince1970
        dict["code"] = code.truncate(255)
        
        let versionId = KMUserDefaults.versionId()
        if versionId > 0 {
            dict["versionId"] = versionId
        }
        return dict
    }
    
    class func errorDict(_ error: String, isInternal: Bool) -> [String: Any] {
        var dict = [String: Any]()
        dict["timestamp"] = Date().timeIntervalSince1970
        dict["error"] = error.truncate(1000)
        dict["isInternal"] = isInternal
        
        let versionId = KMUserDefaults.versionId()
        if versionId > 0 {
            dict["versionId"] = versionId
        }
        return dict
    }
    
    class func inAppPurchaseDict(_ product: SKProduct, quantity: Int, funnel: KMPurchaseFunnel, purchaseType: KMPurchaseType?) -> [String: Any] {
        let pType: KMPurchaseType
        if product.isDownloadable == true {
            pType = KMPurchaseType.appleInAppNonConsumable
        } else if purchaseType == nil {
            pType = KMPurchaseType.unknown
        } else {
            pType = purchaseType!
        }
        
        var currencyCode = ""
        if product.priceLocale.currencyCode != nil {
            currencyCode = product.priceLocale.currencyCode!
        }
        
        return KMHelper.purchaseDict(productIdentifier: product.productIdentifier, price: product.price.decimalValue, currencyCode: currencyCode, quantity: quantity, funnel: funnel, purchaseType: pType)
    }
    
    class func purchaseDict(productIdentifier: String, price: Decimal, currencyCode: String, quantity: Int, funnel: KMPurchaseFunnel, purchaseType: KMPurchaseType, expiresDate: Date? = nil, webOrderLineItemId: String = "") -> [String: Any] {
        var dict = [String: Any]()
        dict["timestamp"] = Date().timeIntervalSince1970
        dict["price"] = price
        dict["currencyCode"] = currencyCode
        dict["productIdentifier"] = productIdentifier
        dict["quantity"] = quantity
        dict["funnel"] = funnel.rawValue
        dict["purchaseTypeValue"] = purchaseType.rawValue
        if expiresDate != nil {
            dict["expiresDateSeconds"] = expiresDate!.timeIntervalSince1970
        } else {
            dict["expiresDateSeconds"] = 0
        }
        dict["webOrderLineItemId"] = webOrderLineItemId
    
        dict["deviceId"] = KMUserDefaults.deviceId()

        let versionId = KMUserDefaults.versionId()
        if versionId > 0 {
            dict["versionId"] = versionId
        }
        return dict
    }
    
    class func paymentDict(product: SKProduct, transaction: SKPaymentTransaction) -> [String: Any] {
        var currencyCode = ""
        if product.priceLocale.currencyCode != nil {
            currencyCode = product.priceLocale.currencyCode!
        }
        
        var purchaseType: KMPurchaseType = .unknown
        if transaction.downloads.count > 0 {
            purchaseType = .appleInAppNonConsumable
        }

        if #available(iOS 11.2, *) {
            if product.introductoryPrice != nil {
                purchaseType = .appleInAppAutoRenewableSubscription
            } else if product.subscriptionPeriod != nil {
                purchaseType = .appleInAppSubscription
            }
        }
        var subscriptionGroupIdentifier = ""
        if #available(iOS 12.0, *) {
            if product.subscriptionGroupIdentifier != nil {
                subscriptionGroupIdentifier = product.subscriptionGroupIdentifier!
                if purchaseType == .unknown {
                    purchaseType = .appleInAppSubscription
                }
            }
        }
        
        var dict = [String: Any]()
        dict["timestamp"] = Date().timeIntervalSince1970
        dict["transactionIdentifier"] = transaction.transactionIdentifier
        dict["price"] = product.price.decimalValue
        dict["currencyCode"] = currencyCode
        dict["productIdentifier"] = product.productIdentifier
        dict["quantity"] = transaction.payment.quantity
        dict["funnel"] = KMPurchaseFunnel.purchase.rawValue
        dict["purchaseTypeValue"] = purchaseType.rawValue
        dict["subscriptionGroupIdentifier"] = subscriptionGroupIdentifier
        
        
        if #available(iOS 11.2, *) {
            if product.subscriptionPeriod != nil {
                let subscriptionPeriod = product.subscriptionPeriod!
                dict["subscriptionNumberOfUnits"] = subscriptionPeriod.numberOfUnits
                dict["subscriptionUnit"] = subscriptionPeriod.unit.rawValue
            }
            
            if product.introductoryPrice != nil {
                let productDiscount = product.introductoryPrice!
                dict["introPrice"] = productDiscount.price.decimalValue
                dict["introPaymentMode"] = productDiscount.paymentMode.rawValue
                dict["introNumberOfPeriods"] = productDiscount.numberOfPeriods
                
                let introSubscriptionPeriod = productDiscount.subscriptionPeriod
                dict["introNumberOfUnits"] = introSubscriptionPeriod.numberOfUnits
                dict["introUnit"] = introSubscriptionPeriod.unit.rawValue
            }
        }
        
        dict["deviceId"] = KMUserDefaults.deviceId()
 
        let versionId = KMUserDefaults.versionId()
        if versionId > 0 {
            dict["versionId"] = versionId
        }
        return dict
    }
    
    class func applicationJson() -> Data? {
        return jsonFromDictionary(applicationDict())
    }
    
    class func deviceJson() -> Data? {
        return jsonFromDictionary(deviceDict())
    }
    
    class func deviceAttributionTokenJson() -> Data? {
        return jsonFromDictionary(deviceAttributionTokenDict())
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
    
    class func inAppPurchaseJson(_ product: SKProduct, quantity: Int, funnel: KMPurchaseFunnel, purchaseType: KMPurchaseType?)-> Data? {
        return jsonFromDictionary(inAppPurchaseDict(product, quantity: quantity, funnel: funnel, purchaseType: purchaseType))
    }
    
    class func purchaseJson(productIdentifier: String, price: Decimal, currencyCode: String, quantity: Int, funnel: KMPurchaseFunnel, purchaseType: KMPurchaseType, expiresDate: Date? = nil, webOrderLineItemId: String = "")-> Data? {
        return jsonFromDictionary(purchaseDict(productIdentifier: productIdentifier, price: price, currencyCode: currencyCode, quantity: quantity, funnel: funnel, purchaseType: purchaseType, expiresDate: expiresDate, webOrderLineItemId: webOrderLineItemId))
    }
    
    class func paymentJson(product: SKProduct, transaction: SKPaymentTransaction) -> Data? {
        return jsonFromDictionary(paymentDict(product: product, transaction: transaction))
    }
    
    class func jsonFromDictionary(_ dictionary: [AnyHashable:Any], logErrors: Bool = true) -> Data? {
        do {
            if KMLog.debug {
                print(dictionary)
            }
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: JSONSerialization.WritingOptions())
            return jsonData
        } catch {
            if logErrors {
                KMError.logError(error)
            } else {
                KMError.printError(error.localizedDescription)
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
            KMError.logError(error)
        }

        return nil
    }
    
}
