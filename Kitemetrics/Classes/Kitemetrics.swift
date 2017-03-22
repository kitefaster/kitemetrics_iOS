//
//  Kitemetrics.swift
//  Pods
//
//  Created by Kitefaster on 10/18/16.
//  Copyright © 2017 Kitefaster, LLC. All rights reserved.
//

import StoreKit
import iAd


///Kitemetrics iOS Client SDK
@objc
public class Kitemetrics: NSObject {

    ///Kitemetrics singleton
    public static let shared = Kitemetrics()
    
    static let kServer = "https://cloud.kitemetrics.com:443"
    static let kAPI = "/api/v1/"
    static let kApplications = "applications"
    static let kDevices = "devices"
    static let kVersions = "versions"
    static let kSessions = "sessions"
    static let kEvents = "events"
    static let kEventSignUps = "eventSignUps"
    static let kEventInvites = "eventInvites"
    static let kErrors = "errors"
    static let kPurchases = "purchases"
    static let kAttributions = "attributions"
    static let kAPIKey = "apiKey"
    static let kApplicationsEndpoint = kServer + kAPI + kApplications
    static let kDevicesEndpoint = kServer + kAPI + kDevices
    static let kVersionsEndpoint = kServer + kAPI + kVersions
    static let kSessionsEndpoint = kServer + kAPI + kSessions
    static let kEventsEndpoint = kServer + kAPI + kEvents
    static let kEventSignUpsEndpoint = kServer + kAPI + kEventSignUps
    static let kEventInviteEndpoint = kServer + kAPI + kEventInvites
    static let kErrorsEndpoint = kServer + kAPI + kErrors
    static let kPurchasesEndpoint = kServer + kAPI + kPurchases
    static let kAttributionsEndpoint = kServer + kAPI + kAttributions
    
    var apiKey: String = ""
    public var userIdentifier: String = ""
    let timerManager = KFTimerManager()
    let sessionManager = KFSessionManager()
    let queue = KFQueue()
    var currentBackoffMultiplier = 1
    var currentBackoffValue = 1
    
    override init() {
        super.init()
        KFLog.p("Kitemetrics shared instance initialized!")
        sessionManager.delegate = self
    }
    
    ///Call on app startup, preferablly in AppDelegate application(_:didFinishLaunchingWithOptions:)
    ///- parameter apiKey: Obtain the apiKey from http://kitemetrics.com
    ///- parameter userIdentifier: Optional.  This is used for tracking the number of active users.  Do not use Personally Identifiable Information (e.g. email addresses, phone numbers, full name, social security numbers, etc).
    public func initSession(apiKey: String, userIdentifier: String? = "") {
        KFLog.p("Kitemetrics shared instance initialized with apiKey!")
        self.apiKey = apiKey
        
        var uid = userIdentifier
        if uid == nil {
            uid = ""
        }
        if uid != "" {
            if isEmailAddress(inputString: uid!) {
                KFError.printError("Do not use Personally Identifiable Information (e.g. email addresses, phone numbers, full name, social security numbers, etc) as the userIdentifier.")
                uid = ""
            } else {
                self.userIdentifier = uid!
            }
        } else {
            let lastVersion = KFUserDefaults.lastVersion()
            if lastVersion != nil && lastVersion!["userIdentifier"] != "" {
                self.userIdentifier = lastVersion!["userIdentifier"]!
            }
        }
        
        appLaunch()
    }
    
    func isEmailAddress(inputString: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: inputString)
    }
    
    func appLaunch() {
        KFLog.p("App Launch")
        let lastVersion = KFUserDefaults.lastVersion()
        let currentVersion = KFHelper.versionDict()
        
        if lastVersion == nil {
            //This is a new install or a reinstall
            postApplication()
            postDevice()
            postVersion(currentVersion, installType: KFInstallType.newInstall)
            KFUserDefaults.setNeedsSearchAdsAttribution(true)
            KFUserDefaults.setLastVersion(currentVersion)
            KFUserDefaults.setLastAttemptToSendErrorQueue(Date())
        } else if lastVersion! != currentVersion {
            KFUserDefaults.setVersionId(kitemetricsVersionId: nil)
            if lastVersion!["appVersion"] != currentVersion["appVersion"] {
                postVersion(currentVersion, installType: KFInstallType.appVersionUpdate)
            } else if lastVersion!["userIdentifier"] != currentVersion["userIdentifier"] {
                postVersion(currentVersion, installType: KFInstallType.userChange)
            } else {
                postVersion(currentVersion, installType: KFInstallType.osChange)
            }
            KFUserDefaults.setLastVersion(currentVersion)
        }
        
        self.queue.startSending()
        self.timerManager.performForegroundActions()
        
        if KFUserDefaults.needsSearchAdsAttribution() {
            //Click Latency
            //Most users that click on a Search Ads impression immediately download the app. When the app is opened immediately and the
            //Search Ads Attribution API is called, the corresponding ad click might not have been processed by our system yet due to some
            //latency. We recommend setting a delay of a few seconds before retrieving attribution data.
            //Source: https://searchads.apple.com/help/pdf/attribution-api.pdf
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.postSearchAdsAttribution()
            }
        }
    }
    
    func postApplication() {
        var request = URLRequest(url: URL(string: Kitemetrics.kApplicationsEndpoint)!)
        guard let json = KFHelper.applicationJson() else {
            return
        }
        request.httpBody = json
        self.queue.addItem(item: request)
    }
    
    func postDevice() {
        var request = URLRequest(url: URL(string: Kitemetrics.kDevicesEndpoint)!)
        guard let json = KFHelper.deviceJson() else {
            return
        }
        request.httpBody = json
        self.queue.addItem(item: request)
    }
    
    func postVersion(_ versionDict: [String: Any], installType: KFInstallType) {
        var modifiedVersionDict = versionDict
        modifiedVersionDict["timestamp"] = Date().timeIntervalSince1970
        modifiedVersionDict["installType"] = installType.rawValue
        
        if let applicationId = KFUserDefaults.applicationId() {
            if applicationId > 0 {
                modifiedVersionDict["applicationId"] = applicationId
            } else {
                modifiedVersionDict["bundleId"] = KFDevice.appBundleId()
            }
        }

        if let deviceId = KFUserDefaults.deviceId() {
            if deviceId > 0 {
                modifiedVersionDict["deviceId"] = deviceId
            } else {
                modifiedVersionDict["deviceIdForVendor"] = KFDevice.identifierForVendor()
            }
        }

        var request = URLRequest(url: URL(string: Kitemetrics.kVersionsEndpoint)!)
        guard let json = KFHelper.jsonFromDictionary(modifiedVersionDict) else {
            return
        }
        request.httpBody = json
        
        self.queue.addItem(item: request)
    }
    
    ///Log a custom event.
    ///- parameter eventName: Max size of 255
    public func logEvent(_ eventName: String) {
        postEvent(eventName)
    }
    
    func postEvent(_ event: String) {
        if event.characters.count > 255 {
            KFError.printError("Length of event must be less than 256 characters. Truncating.")
        }
        var request = URLRequest(url: URL(string: Kitemetrics.kEventsEndpoint)!)
        guard let json = KFHelper.eventJson(event) else {
            return
        }
        request.httpBody = json
        
        self.queue.addItem(item: request)
    }
    
    ///Log when a user signs up or creates an account.
    ///- parameter method: The method used to sign up (e.g. Facebook, Google, Email)
    ///- parameter userIdentifier: This is used for tracking the number of active users.  Do not use Personally Identifiable Information (e.g. email addresses, phone numbers, full name, social security numbers, etc).
    public func logSignUp(method: String, userIdentifier: String) {
        if method.characters.count > 255 {
            KFError.printError("Length of method must be less than 256 characters. Truncating.")
        }
        if userIdentifier.characters.count == 0 {
            KFError.printError("Length of userIdentifier must be greater than 0 characters.")
            return
        }
        if userIdentifier.characters.count > 255 {
            KFError.printError("Length of userIdentifier must be less than 256 characters. Truncating.")
        }
        
        if isEmailAddress(inputString: userIdentifier) {
            KFError.printError("Do not use Personally Identifiable Information (e.g. email addresses, phone numbers, full name, social security numbers, etc) as the userIdentifier.")
            return
        }

        //Create a new version first
        Kitemetrics.shared.userIdentifier = userIdentifier
        let currentVersion = KFHelper.versionDict()
        KFUserDefaults.setLastVersion(currentVersion)
        postVersion(currentVersion, installType: KFInstallType.userChange)
        
        var request = URLRequest(url: URL(string: Kitemetrics.kEventSignUpsEndpoint)!)
        guard let json = KFHelper.eventSignUpJson(method: method, userIdentifier: userIdentifier) else {
            return
        }
        request.httpBody = json
        
        self.queue.addItem(item: request)
    }
    
    ///Log when a user shares or invites someone to use the app.
    ///- parameter method: The method used to send the invite (e.g. Facebook, Twitter, Email, Text)
    ///- parameter code: Optional. Referral or other invite code used.
    public func logInvite(method: String, code: String?) {
        if method.characters.count > 255 {
            KFError.printError("Length of method must be less than 256 characters. Truncating.")
        }
        
        if code != nil && code!.characters.count > 255 {
            KFError.printError("Length of code must be less than 256 characters. Truncating.")
        }
        
        var request = URLRequest(url: URL(string: Kitemetrics.kEventInviteEndpoint)!)
        guard let json = KFHelper.eventInviteJson(method: method, code: code) else {
            return
        }
        request.httpBody = json
        
        self.queue.addItem(item: request)
    }
    
    ///Log an error message
    ///- errorMessage: Max size of 1000
    public func logError(_ errorMessage: String) {
        postError(errorMessage, isInternal: false)
    }
    
    func postError(_ error: String, isInternal: Bool) {
        if error.characters.count > 1000 {
            KFError.printError("Length of error must be less than 1000 characters. Truncating.")
        }
        
        var request = URLRequest(url: URL(string: Kitemetrics.kErrorsEndpoint)!)
        guard let json = KFHelper.errorJson(error, isInternal: isInternal) else {
            return
        }
        request.httpBody = json
        
        self.queue.addItem(item: request)
    }
    
    ///Log when a user adds an in-app item to their cart
    public func logAddToCart(_ product: SKProduct, quantity: Int, purchaseType: KFPurchaseTypeValue? = .appleInAppUnknown) {
        var request = URLRequest(url: URL(string: Kitemetrics.kPurchasesEndpoint)!)
        guard let json = KFHelper.purchaseJson(product, quantity: quantity, funnel: KFPurchaseFunnel.addToCart, purchaseType: purchaseType) else {
            return
        }
        request.httpBody = json
        
        self.queue.addItem(item: request)
    }
    
    ///Log when a user completes an in-app purchase
    public func logPurchase(_ product: SKProduct, quantity: Int, purchaseType: KFPurchaseTypeValue? = .appleInAppUnknown) {
        var request = URLRequest(url: URL(string: Kitemetrics.kPurchasesEndpoint)!)
        guard let json = KFHelper.purchaseJson(product, quantity: quantity, funnel: KFPurchaseFunnel.purchase, purchaseType: purchaseType) else {
            return
        }
        request.httpBody = json

        self.queue.addItem(item: request)
    }
    
    func postSearchAdsAttribution() {
        if #available(iOS 10.0, *) {
            ADClient.shared().requestAttributionDetails({ (attributionDetails: [AnyHashable : Any]?, error: Error?) in
                if error != nil {
                    let adClientError = error as! ADClientError
                    if adClientError.code == ADClientError.unknown {
                        //Apple Search Ads server is down.  Retry in 15 minutes.
                        DispatchQueue.main.asyncAfter(deadline: .now() + 900.0) {
                            self.postSearchAdsAttribution()
                        }
                    } else if adClientError.code == ADClientError.limitAdTracking {
                        KFUserDefaults.setNeedsSearchAdsAttribution(false)
                    } else {
                        KFError.logError(error!)
                    }
                } else if attributionDetails != nil {
                    guard let jsonData = KFHelper.jsonFromDictionary(attributionDetails!) else {
                        return
                    }
                    self.postAttribution(jsonData)
                    KFUserDefaults.setNeedsSearchAdsAttribution(false)
                } else {
                    KFError.logErrorMessage("nil attribuiton and nil error.")
                }
            })
        }
    }

    
    func postAttribution(_ attribuiton: Data) {
        var request = URLRequest(url: URL(string: Kitemetrics.kAttributionsEndpoint)!)
        request.httpBody = attribuiton
        
        self.queue.addItem(item: request)
    }
    
    
}

extension Kitemetrics: KFSessionManagerDelegate {
    
    func sessionReadyToPost(launchTime: Date, closeTime: Date) {
        var request = URLRequest(url: URL(string: Kitemetrics.kSessionsEndpoint)!)
        request.httpBody = KFHelper.sessionJson(launchTime: launchTime, closeTime: closeTime)
        
        self.queue.addItem(item: request)
    }
    
}
