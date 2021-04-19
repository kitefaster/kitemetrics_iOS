//
//  KMRequest.swift
//  Kitemetrics
//
//  Created by Kitemetrics on 10/31/16.
//  Copyright © 2021 Kitemetrics. All rights reserved.
//

import Foundation

class KMRequest {
    
    var requestApplicationId = false
    var requestDeviceId = false
    var requestVersionId = false
    var queue: KMQueue? = nil
    
    func postRequest(_ storedRequest: URLRequest, filename: URL?, isImmediate: Bool = false) {
        KMLog.p("Sending request to " + storedRequest.url!.absoluteString)
        if Kitemetrics.shared.apiKey == "API_KEY" {
            return
        }
        
        
        var request = storedRequest
        request.httpMethod = "POST"
        
        request.setValue(Kitemetrics.shared.apiKey, forHTTPHeaderField: "apiKey")
        request.setValue(Kitemetrics.kitemetricsClientVersion, forHTTPHeaderField: "kitemetrics-client-version")
        request.httpShouldHandleCookies = false
        request.allowsCellularAccess = true
        
        if request.url?.absoluteString == Kitemetrics.kReceiptsEndpoint {
            request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        } else {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        let sendToServer = request.url?.absoluteString != Kitemetrics.kErrorsEndpoint
        
        if request.url?.absoluteString != Kitemetrics.kDevicesEndpoint &&
            request.url?.absoluteString != Kitemetrics.kVersionsEndpoint &&
            request.url?.absoluteString != Kitemetrics.kApplicationsEndpoint {
            var dictionary = KMHelper.dictionaryFromJson(request.httpBody!)
            
            if dictionary != nil {
                if dictionary!["applicationId"] == nil {
                    let applicationId = KMUserDefaults.applicationId()
                    if applicationId > 0 {
                        dictionary!["applicationId"] = applicationId
                    } else {
                        postImmediateApplication()
                    }
                }
                
                if dictionary!["deviceId"] == nil {
                    let deviceId = KMUserDefaults.deviceId()
                    if deviceId > 0 {
                        dictionary!["deviceId"] = deviceId
                    } else {
                        postImmediateDeviceId()
                        dictionary!["deviceIdForVendor"] = KMDevice.identifierForVendor()
                    }
                }
                
                if dictionary!["versionId"] == nil {
                    let versionId = KMUserDefaults.versionId()
                    if versionId > 0 {
                        dictionary!["versionId"] = versionId
                    } else {
                        postImmediateVersionId()
                        
                        if request.url?.absoluteString == Kitemetrics.kAttributionsEndpoint && self.queue != nil {
                            //add to bottom of queue to send again later with the versionId.
                            self.queue!.addItem(item: storedRequest)
                            return
                        }
                    }
                }
                
                if request.url?.absoluteString == Kitemetrics.kAttributionsEndpoint {
                    //Append attempt number to dictionary
                    dictionary!["attempt"] = KMUserDefaults.attributionRequestAttemptNumber()
                    let attributionClientVersionId = KMUserDefaults.attributionClientVersionId()
                    if attributionClientVersionId == 0 {
                        KMUserDefaults.setAttributionClientVersionId()
                    } else {
                        //Always use original versionId when sending the attribution
                        dictionary!["versionId"] = attributionClientVersionId
                    }
                }

                request.httpBody = KMHelper.jsonFromDictionary(dictionary!)
            }
        }
        
        let deviceTimestamp = String(Date().timeIntervalSince1970)
        request.setValue(deviceTimestamp, forHTTPHeaderField: "X-Device-Timestamp")
        
        URLSession.shared.dataTask(with: request) {data, response, err in
            Kitemetrics.shared.currentBackoffValue = 1
            var userInfo : [String : Any]
            if filename == nil {
                userInfo = ["request" : request]
            } else {
                userInfo = ["filename": filename!, "request" : request]
            }
            
            if err != nil {
                let error: NSError = err! as NSError
                if (error.domain == NSURLErrorDomain || error.domain == kCFErrorDomainCFNetwork as String) && (error.code == -1001 || error.code == -1004){
                    //server down, increase timeout
                    Kitemetrics.shared.currentBackoffMultiplier = Kitemetrics.shared.currentBackoffMultiplier + 1
                    KMLog.p("Timeout.  Set backoff to " + String(Kitemetrics.shared.currentBackoffMultiplier))
                    //Do not send notification.  Will attempt to resend again.
                } else {
                    KMLog.p("Debug err: " + err.debugDescription)
                    KMError.logErrorMessage("Error sending request. " + err!.localizedDescription, sendToServer: sendToServer)
                    if !isImmediate {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "com.kitefaster.KFRequest.Post.Error"), object: nil, userInfo: userInfo)
                    }
                }
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                KMError.logErrorMessage("HTTPURLResponse is nil.", sendToServer: sendToServer)
                if !isImmediate {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "com.kitefaster.KFRequest.Post.Error"), object: nil, userInfo: userInfo)
                }
                return
            }
            
            let statusCode = httpResponse.statusCode
            
            if statusCode == 200 {
                do{
                    Kitemetrics.shared.currentBackoffMultiplier = 1
                    if request.url!.absoluteString.hasSuffix(Kitemetrics.kApplications) {
                        if let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as? [String: Any] {
                            if let id = json["id"] as? Int {
                                KMLog.p("application id: " + String(id))
                                KMUserDefaults.setApplicationId(id)
                            }
                        }
                    } else if request.url!.absoluteString.hasSuffix(Kitemetrics.kDevices) || request.url!.absoluteString.hasSuffix(Kitemetrics.kAttributionTokens) {
                        if let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as? [String: Any] {
                            if let id = json["id"] as? Int {
                                KMLog.p("device id: " + String(id))
                                KMUserDefaults.setDeviceId(id)
                            }
                        }
                    } else if request.url!.absoluteString.hasSuffix(Kitemetrics.kVersions) {
                        if let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as? [String: Any]{
                            if let id = json["id"] as? Int {
                                KMLog.p("version id: " + String(id))
                                KMUserDefaults.setVersionId(kitemetricsVersionId: id)
                            }
                        }
                    } else  {
                        KMLog.p("Posted " + request.url!.lastPathComponent)
                    }
                    if !isImmediate {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "com.kitefaster.KFRequest.Post.Success"), object: nil, userInfo: userInfo)
                    }
                } catch {
                    KMError.logErrorMessage("Error with Json from 200: \(error.localizedDescription)", sendToServer: sendToServer)
                    if !isImmediate {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "com.kitefaster.KFRequest.Post.Error"), object: nil, userInfo: userInfo)
                    }
                }
            } else if statusCode == 204 {
                KMLog.p("Posted " + request.url!.lastPathComponent)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "com.kitefaster.KFRequest.Post.Success"), object: nil, userInfo: userInfo)
            } else {
                if statusCode == 502 || statusCode == 404 {
                    //server down, increase timeout
                    Kitemetrics.shared.currentBackoffMultiplier = Kitemetrics.shared.currentBackoffMultiplier + 1
                    KMLog.p("Timeout. Set backoff to " + String(Kitemetrics.shared.currentBackoffMultiplier))
                    //Do not send notification.  Will attempt to resend again.
                } else if KMLog.debug {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as? [String: String] {
                            if let error = json["error"] {
                                KMError.logErrorMessage(error, sendToServer: false)
                                if !isImmediate {
                                    NotificationCenter.default.post(name: Notification.Name(rawValue: "com.kitefaster.KFRequest.Post.Error"), object: nil, userInfo: userInfo)
                                }
                            }
                        }
                    } catch {
                        KMError.logErrorMessage("Error with Json from \(statusCode): \(error.localizedDescription)", sendToServer: sendToServer)
                        if !isImmediate {
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "com.kitefaster.KFRequest.Post.Error"), object: nil, userInfo: userInfo)
                        }
                    }
                }
            }
        }.resume()
    }
    
    func postImmediateApplication() {
        if self.requestApplicationId == false {
            KMError.logErrorMessage("Need application Id", sendToServer: false)
            self.requestApplicationId = true
            var request = URLRequest(url: URL(string: Kitemetrics.kApplicationsEndpoint)!)
            guard let json = KMHelper.applicationJson() else {
                return
            }
            request.httpBody = json
        
            postRequest(request, filename: nil, isImmediate: true)
        }
    }
    
    func postImmediateDeviceId() {
        if self.requestDeviceId == false {
            KMError.logErrorMessage("Need device Id", sendToServer: false)
            self.requestDeviceId = true
            var request = URLRequest(url: URL(string: Kitemetrics.kDevicesEndpoint)!)
            guard let json = KMHelper.deviceJson() else {
                return
            }
            request.httpBody = json
            
            postRequest(request, filename: nil, isImmediate: true)
        }
    }
    
    func postImmediateVersionId() {
        if self.requestVersionId == false {
            KMError.logErrorMessage("Need version Id", sendToServer: false)
            self.requestVersionId = true
            
            //TODO: Refactor duplicate code from Kitemetrics.appLaunch()
            let lastVersion = KMUserDefaults.lastVersion()
            let currentVersion = KMHelper.versionDict()
            
            var installType = KMInstallType.unknown
            if lastVersion == nil {
                installType = KMInstallType.newInstall
            } else if lastVersion! != currentVersion {
                if lastVersion!["appVersion"] != currentVersion["appVersion"] {
                    installType = KMInstallType.appVersionUpdate
                } else if lastVersion!["userIdentifier"] != currentVersion["userIdentifier"] {
                    installType = KMInstallType.userChange
                } else if lastVersion!["osVersion"] != currentVersion["osVersion"] || lastVersion!["osCountry"] != currentVersion["osCountry"] || lastVersion!["osLanguage"] != currentVersion["osLanguage"] {
                    installType = KMInstallType.osChange
                }
            }
            KMUserDefaults.setLastVersion(currentVersion)
            
            
            var modifiedVersionDict: [String: Any] = currentVersion
            modifiedVersionDict["timestamp"] = Date().timeIntervalSince1970
            modifiedVersionDict["installType"] = installType.rawValue
            
            let applicationId = KMUserDefaults.applicationId()
            if applicationId > 0 {
                modifiedVersionDict["applicationId"] = applicationId
            } else {
                modifiedVersionDict["bundleId"] = KMDevice.appBundleId()
            }
            
            let deviceId = KMUserDefaults.deviceId()
            if deviceId > 0 {
                modifiedVersionDict["deviceId"] = deviceId
            } else {
                modifiedVersionDict["deviceIdForVendor"] = KMDevice.identifierForVendor()
            }

            var request = URLRequest(url: URL(string: Kitemetrics.kVersionsEndpoint)!)
            guard let json = KMHelper.jsonFromDictionary(modifiedVersionDict) else {
                return
            }
            request.httpBody = json
            
            postRequest(request, filename: nil, isImmediate: true)
        }
    }
    
}
