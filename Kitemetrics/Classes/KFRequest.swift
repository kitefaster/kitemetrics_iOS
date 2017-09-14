//
//  KFRequest.swift
//  Pods
//
//  Created by Kitefaster on 10/31/16.
//  Copyright © 2017 Kitefaster, LLC. All rights reserved.
//

import Foundation


class KFRequest {
    
    var requestApplicationId = false;
    var requestDeviceId = false;
    var requestVersionId = false;
    
    func postRequest(_ storedRequest: URLRequest, filename: URL?, isImmediate: Bool = false) {
        KFLog.p("Sending request to " + storedRequest.url!.absoluteString)
        
        var request = storedRequest
        request.httpMethod = "POST"
        request.setValue(Kitemetrics.shared.apiKey, forHTTPHeaderField: Kitemetrics.kAPIKey)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpShouldHandleCookies = false
        request.allowsCellularAccess = true
        
        let sendToServer = request.url?.absoluteString != Kitemetrics.kErrorsEndpoint
        
        if request.url?.absoluteString != Kitemetrics.kDevicesEndpoint &&
            request.url?.absoluteString != Kitemetrics.kVersionsEndpoint &&
            request.url?.absoluteString != Kitemetrics.kApplicationsEndpoint {
            var dictionary = KFHelper.dictionaryFromJson(request.httpBody!)
            
            if dictionary != nil {
                if dictionary!["applicationId"] == nil, let applicationId = KFUserDefaults.applicationId() {
                    if applicationId > 0 {
                        dictionary!["applicationId"] = applicationId
                    } else {
                        postImmediateApplication()
                    }
                }
                
                if dictionary!["deviceId"] == nil, let deviceId = KFUserDefaults.deviceId() {
                    if deviceId > 0 {
                        dictionary!["deviceId"] = deviceId
                    } else {
                        postImmediateDeviceId()
                    }
                }
                
                if dictionary!["versionId"] == nil, let versionId = KFUserDefaults.versionId() {
                    if versionId > 0 {
                        dictionary!["versionId"] = versionId
                    } else {
                        postImmediateVersionId()
                    }
                }

                request.httpBody = KFHelper.jsonFromDictionary(dictionary!)
            }
        }
        
        URLSession.shared.dataTask(with: request) {data, response, err in
            var userInfo : [String : Any]
            if filename == nil {
                userInfo = ["request" : request]
            } else {
                 userInfo = ["filename": filename!, "request" : request]
            }
            
            if err != nil {
                KFError.logErrorMessage("Error sending request. " + err!.localizedDescription, sendToServer: sendToServer)
                if !isImmediate {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "com.kitefaster.KFRequest.Post.Error"), object: nil, userInfo: userInfo)
                }
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                KFError.logErrorMessage("HTTPURLResponse is nil.", sendToServer: sendToServer)
                if !isImmediate {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "com.kitefaster.KFRequest.Post.Error"), object: nil, userInfo: userInfo)
                }
                return
            }
            
            let statusCode = httpResponse.statusCode
            Kitemetrics.shared.currentBackoffValue = 1
            
            if (statusCode == 200) {
                do{
                    Kitemetrics.shared.currentBackoffMultiplier = 1
                    if request.url!.absoluteString.hasSuffix(Kitemetrics.kApplications) {
                        let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String: Any]
                        
                        if let id = json["id"] as? Int {
                            KFLog.p("application id: " + String(id))
                            KFUserDefaults.setApplicationId(kitemetricsApplicationId: id)
                        }
                    } else if request.url!.absoluteString.hasSuffix(Kitemetrics.kDevices) {
                        let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String: Any]
                        
                        if let id = json["id"] as? Int {
                            KFLog.p("device id: " + String(id))
                            KFUserDefaults.setDeviceId(kitemetricsDeviceId: id)
                        }
                    } else if request.url!.absoluteString.hasSuffix(Kitemetrics.kVersions) {
                        let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String: Any]
                        
                        if let id = json["id"] as? Int {
                            KFLog.p("version id: " + String(id))
                            KFUserDefaults.setVersionId(kitemetricsVersionId: id)
                        }
                    } else  {
                        KFLog.p("Posted " + request.url!.lastPathComponent)
                    }
                    if !isImmediate {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "com.kitefaster.KFRequest.Post.Success"), object: nil, userInfo: userInfo)
                    }
                } catch {
                    KFError.logErrorMessage("Error with Json from 200: \(error.localizedDescription)", sendToServer: sendToServer)
                    if !isImmediate {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "com.kitefaster.KFRequest.Post.Error"), object: nil, userInfo: userInfo)
                    }
                }
            } else {
                if statusCode == 502 || statusCode == 404 {
                    //server down, increase timeout
                    Kitemetrics.shared.currentBackoffMultiplier = Kitemetrics.shared.currentBackoffMultiplier + 1
                    KFLog.p("set backoff to " + String(Kitemetrics.shared.currentBackoffMultiplier))
                    //Do not send notification.  Will attempt to resend again.
                } else if KFLog.debug {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String: String]
                        if let error = json["error"] {
                            KFError.logErrorMessage(error, sendToServer: false)
                            if !isImmediate {
                                NotificationCenter.default.post(name: Notification.Name(rawValue: "com.kitefaster.KFRequest.Post.Error"), object: nil, userInfo: userInfo)
                            }
                        }
                    } catch {
                        KFError.logErrorMessage("Error with Json from \(statusCode): \(error.localizedDescription)", sendToServer: sendToServer)
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
            KFError.logErrorMessage("Need application Id", sendToServer: true)
            self.requestApplicationId = true
            var request = URLRequest(url: URL(string: Kitemetrics.kApplicationsEndpoint)!)
            guard let json = KFHelper.applicationJson() else {
                return
            }
            request.httpBody = json
        
            postRequest(request, filename: nil, isImmediate: true)
        }
    }
    
    func postImmediateDeviceId() {
        if self.requestDeviceId == false {
            KFError.logErrorMessage("Need device Id", sendToServer: true)
            self.requestDeviceId = true
            var request = URLRequest(url: URL(string: Kitemetrics.kDevicesEndpoint)!)
            guard let json = KFHelper.deviceJson() else {
                return
            }
            request.httpBody = json
            
            postRequest(request, filename: nil, isImmediate: true)
        }
    }
    
    func postImmediateVersionId() {
        if self.requestVersionId == false {
            KFError.logErrorMessage("Need version Id", sendToServer: true)
            self.requestVersionId = true
            
            //TODO: Refactor duplicate code from Kitemetrics.appLaunch()
            let lastVersion = KFUserDefaults.lastVersion()
            let currentVersion = KFHelper.versionDict()
            
            var installType = KFInstallType.unknown
            if lastVersion == nil {
                installType = KFInstallType.newInstall
            } else if lastVersion! != currentVersion {
                if lastVersion!["appVersion"] != currentVersion["appVersion"] {
                    installType = KFInstallType.appVersionUpdate
                } else if lastVersion!["userIdentifier"] != currentVersion["userIdentifier"] {
                    installType = KFInstallType.userChange
                } else if lastVersion!["osVersion"] != currentVersion["osVersion"] || lastVersion!["osCountry"] != currentVersion["osCountry"] || lastVersion!["osLanguage"] != currentVersion["osLanguage"] {
                    installType = KFInstallType.osChange
                }
            }
            KFUserDefaults.setLastVersion(currentVersion)
            
            
            var modifiedVersionDict: [String: Any] = currentVersion
            modifiedVersionDict["timestamp"] = Kitemetrics.shared.timeIntervalSince1970()
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
            
            postRequest(request, filename: nil, isImmediate: true)
        }
    }
    
}
