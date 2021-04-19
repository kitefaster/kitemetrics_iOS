//
//  KMQueue.swift
//  Kitemetrics
//
//  Created by Kitemetrics on 10/31/16.
//  Copyright © 2021 Kitemetrics. All rights reserved.
//

import Foundation


class KMQueue {
    
    let reachability = KFReachability(hostname: Kitemetrics.kServer)!
    let requester = KMRequest()
    var queue = [URLRequest]()
    var outgoingRequests = [URL: Int]()
    
    var filesToSend: [URL]?
    var errorFilesToSend: [URL]?
    var requestsToSend: [URLRequest]?
    var currentFile: URL?
    var newFilesToLoad = false
    var errorOnLastSend = false
    var isApiKeySet = false
    
    let mutex = KMThreadMutex()
    let errorMutex = KMThreadMutex()
    
    static let kMaxQueueSize = 30
    static let kTimeToWaitBeforeSendingMessagesWithErrors = 43200.0 // 12 hours
    static let kMaxQueueFilesToSave = 1000
    static let kMaxErrorFilesToSave = 500
    
    init() {
        self.requester.queue = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceivePostSuccess), name: NSNotification.Name(rawValue: "com.kitefaster.KFRequest.Post.Success"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceivePostError), name: NSNotification.Name(rawValue: "com.kitefaster.KFRequest.Post.Error"), object: nil)
        
        KMLog.p("KFQueue init")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func addItem(item: URLRequest) {
        KMLog.p("KFQueue addItem with url: " +  item.url!.absoluteString)
        self.mutex.sync {
            self.queue.append(item)
        }
        
        if self.queue.count > KMQueue.kMaxQueueSize {
            saveQueue()
        }
    }
    
    func saveQueue() {
        self.mutex.sync {
            if self.queue.count > 0 {
                KMLog.p("KFQueue saveQueue, " + String(self.queue.count) + " items.")
                var filePath = queueDirectory()
                let now = String(Date().timeIntervalSinceReferenceDate)
                filePath = filePath.appendingPathComponent(now + ".data", isDirectory: false)
                
                do {
                    let data = NSKeyedArchiver.archivedData(withRootObject: self.queue)
                    try data.write(to: filePath, options: [NSData.WritingOptions.atomic])
                    self.queue.removeAll()
                    self.newFilesToLoad = true
                } catch let error {
                    KMError.logError(error)
                }
                
                //If over file limit, remove older files
                self.removeOldFiles(directory: queueDirectory(), maxFilesToKeep: KMQueue.kMaxQueueFilesToSave)
            }
        }
        
        if isReadyToSend() {
            if self.newFilesToLoad
            && self.currentFile == nil
            && (self.requestsToSend == nil || self.requestsToSend!.count == 0)
            && (self.filesToSend == nil || self.filesToSend!.count == 0) || self.errorOnLastSend {
                startSending()
            } else if (Kitemetrics.shared.currentBackoffMultiplier > 1 && self.currentFile != nil && self.requestsToSend != nil && self.requestsToSend!.count > 0 && self.filesToSend != nil && self.filesToSend!.count > 0) {
                sendNextRequest()
            }
            startSendingErrors()
        }
    }
    
    func removeOldFiles(directory: URL, maxFilesToKeep: Int) {
        let fileManager = FileManager.default
        do {
            var contents: [URL]? = nil
            contents = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: [], options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
            
            //if we have too many files, delete the oldest files
            if contents != nil && contents!.count > maxFilesToKeep {
                let orderedContents = contents!.sorted {a,b in
                    let atime = KMQueue.timeIntervalFromFilename(a.lastPathComponent)
                    let btime = KMQueue.timeIntervalFromFilename(b.lastPathComponent)
                    return atime < btime
                }
                contents = nil
                
                let overage = orderedContents.count - maxFilesToKeep
                for i in 0...overage - 1 {
                    let url = orderedContents[i]
                    do {
                        try FileManager.default.removeItem(at: url)
                    } catch let error {
                        KMError.logError(error)
                    }
                }
            }
        } catch let error {
            KMError.logError(error)
        }
    }
    
    func saveRequestToError(_ request: URLRequest) {
        KMLog.p("KFQueue saveRequestToError")
        self.errorMutex.sync {
            var filePath = queueErrorsDirectory()
            let now = String(Date().timeIntervalSinceReferenceDate)
            filePath = filePath.appendingPathComponent(now + ".errdata", isDirectory: false)
                
            do {
                let data = NSKeyedArchiver.archivedData(withRootObject: request)
                try data.write(to: filePath, options: [NSData.WritingOptions.atomic])
            } catch let error {
                KMError.logError(error)
            }
            
            //If over file limit, remove older files
            self.removeOldFiles(directory: queueErrorsDirectory(), maxFilesToKeep: KMQueue.kMaxErrorFilesToSave)
        }
    }
    
    func loadFilesToSend() {
        KMLog.p("KFQueue loadFilesToSend")
        let fileManager = FileManager.default
        do {
            var contents: [URL]? = nil
            try self.mutex.sync {
                let directory = queueDirectory()
                contents = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: [], options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
                self.newFilesToLoad = false
                
                if contents != nil && contents!.count > 0 {
                    self.filesToSend = contents!.sorted {a,b in
                        let atime = KMQueue.timeIntervalFromFilename(a.lastPathComponent)
                        let btime = KMQueue.timeIntervalFromFilename(b.lastPathComponent)
                        return atime < btime
                    }
                }
            }
        } catch let error {
            KMError.logError(error)
        }
    }
    
    func loadErrorFilesToSend() {
        KMLog.p("KFQueue loadErrorFilesToSend")
        let fileManager = FileManager.default
        do {
            var contents: [URL]? = nil
            try self.errorMutex.sync {
                contents = try fileManager.contentsOfDirectory(at: queueErrorsDirectory(), includingPropertiesForKeys: [], options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
            
                if contents != nil && contents!.count > 0 {
                    self.errorFilesToSend = contents!.sorted {a,b in
                        let atime = KMQueue.timeIntervalFromFilename(a.lastPathComponent)
                        let btime = KMQueue.timeIntervalFromFilename(b.lastPathComponent)
                        return atime < btime
                    }
                }
            }
        } catch let error {
            KMError.logError(error)
        }
    }
    
    func errorRequestToSend() -> (request: URLRequest, file: URL)? {
        KMLog.p("KFQueue errorRequestToSend")
        if self.errorFilesToSend != nil && self.errorFilesToSend!.count > 0 {
            guard let file = self.errorFilesToSend?.first else {
                return nil
            }
            do {
                let data = try Data(contentsOf: file)
                let request = NSKeyedUnarchiver.unarchiveObject(with: data) as? URLRequest
                if request == nil {
                    return nil
                } else {
                    return (request!, file)
                }
            } catch let error {
                KMError.logError(error)
            }
        }
        return nil
    }
    
    func loadRequestsToSend() -> Bool {
        KMLog.p("KFQueue loadRequestsToSend")
        if self.filesToSend != nil && self.filesToSend!.count > 0 {
            guard let file = self.filesToSend?.first else {
                return false
            }
            do {
                let data = try Data(contentsOf: file)
                self.requestsToSend = NSKeyedUnarchiver.unarchiveObject(with: data) as? [URLRequest]
                self.currentFile = file
                return true
            } catch let error {
                KMError.logError(error)
            }
        }
        return false
    }
    
    func sendNextRequest() {
        KMLog.p("KFQueue sendNextRequest")
        self.errorOnLastSend = false
        if isReadyToSend() {
            guard let request = self.requestsToSend?.first else {
                KMError.logErrorMessage("sendNextRequest: Expected to find a request in the queue but it is empty.")
                return
            }
            self.requester.postRequest(request, filename: self.currentFile!)
        }
    }
    
    func sendNextErrorRequest() {
        KMLog.p("KFQueue sendNextErrorRequest")
        if isReadyToSend() {
            guard let (request, file) = errorRequestToSend() else {
                return
            }
            self.requester.postRequest(request, filename: file)
        }
    }
    
    @objc func didReceivePostSuccess(notification: Notification) {
        KMLog.p("KFQueue didReceivePostSuccess")
        if let info = notification.userInfo as? Dictionary<String, Any> {
            guard let filename = info["filename"] as? URL else {
                KMError.logErrorMessage("Post success notification is missing filename.")
                return
            }
            
            if filename.pathExtension == "errdata" {
                removeCurrentErrorSendRequestAndSendNext(filename)
            } else {
                if self.currentFile == filename {
                    removeCurrentSendRequestAndSendNext()
                } else {
                    KMError.logErrorMessage("didReceivePostSuccess: Filenames do not match.")
                }
            }
        }
    }
    
    @objc func didReceivePostError(notification: Notification) {
        KMLog.p("KFQueue didReceivePostError")
        
        if let info = notification.userInfo as? Dictionary<String, Any> {
            guard let filename = info["filename"] as? URL else {
                KMError.logErrorMessage("Post error notification is missing filename.")
                return
            }
            guard var request = info["request"] as? URLRequest else {
                KMError.logErrorMessage("Post error notification is missing request.")
                return
            }
            
            let isOldError = filename.pathExtension == "errdata"
            if isOldError {
                if errorFilesToSend?.first != filename {
                    KMError.logErrorMessage("didReceivePostError oldError: Filenames do not match.")
                    return
                }
            } else {
                if self.currentFile != filename {
                    KMError.logErrorMessage("didReceivePostError: Filenames do not match.")
                    return
                }
            }
            
            let requestAttemptCountStr = request.value(forHTTPHeaderField: "requestAttemptCount")
            var requestAttemptCount: Int? = 1
            if requestAttemptCountStr == nil {
                request.setValue("1", forHTTPHeaderField: "requestAttemptCount")
            } else {
                requestAttemptCount = Int(requestAttemptCountStr!)
                if requestAttemptCount == nil || requestAttemptCountStr == nil {
                    requestAttemptCount = 1
                    request.setValue("1", forHTTPHeaderField: "requestAttemptCount")
                    KMError.logErrorMessage("Could not convert value of requestAttemptCount to int.  value = " + requestAttemptCountStr!)
                }
                requestAttemptCount = requestAttemptCount! + 1
                request.setValue(String(describing: requestAttemptCount!), forHTTPHeaderField: "requestAttemptCount")
            }
                    
            if isOldError {
                do {
                    let data = NSKeyedArchiver.archivedData(withRootObject: request)
                    try data.write(to: filename, options: [NSData.WritingOptions.atomic])
                } catch let error {
                    KMError.logError(error)
                }
                skipCurrentErrorSendRequestAndSendNext(filename)
            } else {
                if requestAttemptCount! >= 3 {
                    saveRequestToError(request)
                    removeCurrentSendRequestAndSendNext()
                } else {
                    self.requestsToSend?[0] = request
                    //overwrite current file with the modified request
                    do {
                        let array = self.requestsToSend!
                        let data = NSKeyedArchiver.archivedData(withRootObject: array)
                        try data.write(to: self.currentFile!, options: [NSData.WritingOptions.atomic])
                    } catch let error {
                        KMError.logError(error)
                    }
                            
                    //Make sure this flag is set last to prevent multi-threading conflicts
                    self.errorOnLastSend = true
                }
            }
        
        }
    }
    
    func removeCurrentSendRequestAndSendNext() {
        KMLog.p("KFQueue removeCurrentSendRequestAndSendNext")
        self.requestsToSend!.remove(at: 0)
        if self.requestsToSend!.count == 0 {
            self.filesToSend!.remove(at: 0)
            do {
                try FileManager.default.removeItem(at: self.currentFile!)
                self.currentFile = nil
            } catch let error {
                KMError.logError(error)
            }
            if loadRequestsToSend() {
                sendNextRequest()
            } else if self.newFilesToLoad {
                startSending()
            }
        } else {
            //overwrite current file without the sent request
            do {
                let array = self.requestsToSend!
                let data = NSKeyedArchiver.archivedData(withRootObject: array)
                try data.write(to: self.currentFile!, options: [NSData.WritingOptions.atomic])
            } catch let error {
                KMError.logError(error)
            }
            sendNextRequest()
        }
    }
    
    func removeCurrentErrorSendRequestAndSendNext(_ filename: URL) {
        KMLog.p("KFQueue removeCurrentErrorSendRequestAndSendNext")
        if self.errorFilesToSend != nil && self.errorFilesToSend![0] == filename {
            self.errorFilesToSend!.remove(at: 0)
        }
        
        do {
            try FileManager.default.removeItem(at: filename)
        } catch let error {
            KMError.logError(error)
        }
        
        sendNextErrorRequest()
    }
    
    func skipCurrentErrorSendRequestAndSendNext(_ filename: URL) {
        KMLog.p("KFQueue skipCurrentErrorSendRequestAndSendNext")
        if self.errorFilesToSend != nil && self.errorFilesToSend![0] == filename {
            self.errorFilesToSend!.remove(at: 0)
        }
        
        sendNextErrorRequest()
    }
    
    func startSending() {
        KMLog.p("KFQueue startSending")
        if isReadyToSend() {
            loadFilesToSend()
            if loadRequestsToSend() {
                sendNextRequest()
            }
        }
    }
    
    func startSendingErrors() {
        guard let lastAttemptDate = KMUserDefaults.lastAttemptToSendErrorQueue() else {
            return
        }
        if fabs(lastAttemptDate.timeIntervalSinceNow) > KMQueue.kTimeToWaitBeforeSendingMessagesWithErrors {
            KMUserDefaults.setLastAttemptToSendErrorQueue(Date())
            loadErrorFilesToSend()
            sendNextErrorRequest()
        }
    }
    
    class func timeIntervalFromFilename(_ filename: String) -> TimeInterval {
        let timeAsString: String
        if filename.contains(".data") {
            timeAsString = filename.replacingOccurrences(of: ".data", with: "")
        } else {
            timeAsString = filename.replacingOccurrences(of: ".errdata", with: "")
        }
        let time = TimeInterval(timeAsString)
        return time!
    }
    
    func applicationLibraryDirectory() -> URL {
        return FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last!
    }
    
    func queueDirectory() -> URL {
        return kitemetricsDirectoryWithSubDir(subdirectory: "queue")
    }
    
    func queueErrorsDirectory() -> URL {
        return kitemetricsDirectoryWithSubDir(subdirectory: "queueErrors")
    }
    
    func kitemetricsDirectoryWithSubDir(subdirectory: String) -> URL {
        let documentsDir = applicationLibraryDirectory()
        
        let path = documentsDir.appendingPathComponent("Application Support", isDirectory:true).appendingPathComponent(KMDevice.appBundleId(), isDirectory:true).appendingPathComponent("Kitemetrics", isDirectory:true).appendingPathComponent(subdirectory, isDirectory:true)
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: path.relativePath) {
            do {
                try fileManager.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                KMError.logError(error)
            }
        }
        
        return path
    }
    
    func isReadyToSend() -> Bool {
        if self.isApiKeySet == false {
            if Kitemetrics.shared.apiKey == "" {
                KMError.logErrorMessage("Kitemetrics needs API Key, or API Key not yet loaded", sendToServer: false)
            } else {
                self.isApiKeySet = true
            }
        }
        
        if self.isApiKeySet && self.reachability.connection != .none {
            if Kitemetrics.shared.currentBackoffValue < Kitemetrics.shared.currentBackoffMultiplier {
                Kitemetrics.shared.currentBackoffValue = Kitemetrics.shared.currentBackoffValue + 1
                KMLog.p("Connection timeout, skip")
                return false
            }
            
            return true
        }
        
        return false
    }
    
}
