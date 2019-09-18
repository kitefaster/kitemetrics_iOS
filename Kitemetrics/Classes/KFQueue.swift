//
//  KFQueue.swift
//  Pods
//
//  Created by Kitefaster on 10/31/16.
//  Copyright © 2017 Kitefaster, LLC. All rights reserved.
//

import Foundation


class KFQueue {
    
    let reachability: KFReachability?
    let requester = KFRequest()
    var queue = [URLRequest]()
    var outgoingRequests = [URL: Int]()
    
    var filesToSend: [URL]?
    var errorFilesToSend: [URL]?
    var requestsToSend: [URLRequest]?
    var currentFile: URL?
    var newFilesToLoad = false
    var errorOnLastSend = false
    var isApiKeySet = false
    
    let mutex = KFThreadMutex()
    let errorMutex = KFThreadMutex()
    
    static let kMaxQueueSize = 30
    static let kTimeToWaitBeforeSendingMessagesWithErrors = 43200.0 // 12 hours
    static let kMaxQueueFilesToSave = 1000
    static let kMaxErrorFilesToSave = 500
    
    init() {
        do {
            self.reachability = try KFReachability(hostname: Kitemetrics.kServer)
        } catch {
            do {
                self.reachability = try KFReachability()
            } catch {
                self.reachability = nil
            }
        }
        self.requester.queue = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceivePostSuccess), name: NSNotification.Name(rawValue: "com.kitefaster.KFRequest.Post.Success"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceivePostError), name: NSNotification.Name(rawValue: "com.kitefaster.KFRequest.Post.Error"), object: nil)
        
        KFLog.p("KFQueue init")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func addItem(item: URLRequest) {
        KFLog.p("KFQueue addItem with url: " +  item.url!.absoluteString)
        self.mutex.sync {
            self.queue.append(item)
        }
        
        if self.queue.count > KFQueue.kMaxQueueSize {
            saveQueue()
        }
    }
    
    func saveQueue() {
        self.mutex.sync {
            if self.queue.count > 0 {
                KFLog.p("KFQueue saveQueue, " + String(self.queue.count) + " items.")
                var filePath = queueDirectory()
                let now = String(Date().timeIntervalSinceReferenceDate)
                filePath = filePath.appendingPathComponent(now + ".data", isDirectory: false)
                
                do {
                    let data = NSKeyedArchiver.archivedData(withRootObject: self.queue)
                    try data.write(to: filePath, options: [NSData.WritingOptions.atomic])
                    self.queue.removeAll()
                    self.newFilesToLoad = true
                } catch let error {
                    KFError.logError(error)
                }
                
                //If over file limit, remove older files
                self.removeOldFiles(directory: queueDirectory(), maxFilesToKeep: KFQueue.kMaxQueueFilesToSave)
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
                    let atime = KFQueue.timeIntervalFromFilename(a.lastPathComponent)
                    let btime = KFQueue.timeIntervalFromFilename(b.lastPathComponent)
                    return atime < btime
                }
                contents = nil
                
                let overage = orderedContents.count - maxFilesToKeep
                for i in 0...overage - 1 {
                    let url = orderedContents[i]
                    do {
                        try FileManager.default.removeItem(at: url)
                    } catch let error {
                        KFError.logError(error)
                    }
                }
            }
        } catch let error {
            KFError.logError(error)
        }
    }
    
    func saveRequestToError(_ request: URLRequest) {
        KFLog.p("KFQueue saveRequestToError")
        self.errorMutex.sync {
            var filePath = queueErrorsDirectory()
            let now = String(Date().timeIntervalSinceReferenceDate)
            filePath = filePath.appendingPathComponent(now + ".errdata", isDirectory: false)
                
            do {
                let data = NSKeyedArchiver.archivedData(withRootObject: request)
                try data.write(to: filePath, options: [NSData.WritingOptions.atomic])
            } catch let error {
                KFError.logError(error)
            }
            
            //If over file limit, remove older files
            self.removeOldFiles(directory: queueErrorsDirectory(), maxFilesToKeep: KFQueue.kMaxErrorFilesToSave)
        }
    }
    
    func loadFilesToSend() {
        KFLog.p("KFQueue loadFilesToSend")
        let fileManager = FileManager.default
        do {
            var contents: [URL]? = nil
            try self.mutex.sync {
                contents = try fileManager.contentsOfDirectory(at: queueDirectory(), includingPropertiesForKeys: [], options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
                self.newFilesToLoad = false
                
                if contents != nil && contents!.count > 0 {
                    self.filesToSend = contents!.sorted {a,b in
                        let atime = KFQueue.timeIntervalFromFilename(a.lastPathComponent)
                        let btime = KFQueue.timeIntervalFromFilename(b.lastPathComponent)
                        return atime < btime
                    }
                }
            }
        } catch let error {
            KFError.logError(error)
        }
    }
    
    func loadErrorFilesToSend() {
        KFLog.p("KFQueue loadErrorFilesToSend")
        let fileManager = FileManager.default
        do {
            var contents: [URL]? = nil
            try self.errorMutex.sync {
                contents = try fileManager.contentsOfDirectory(at: queueErrorsDirectory(), includingPropertiesForKeys: [], options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
            
                if contents != nil && contents!.count > 0 {
                    self.errorFilesToSend = contents!.sorted {a,b in
                        let atime = KFQueue.timeIntervalFromFilename(a.lastPathComponent)
                        let btime = KFQueue.timeIntervalFromFilename(b.lastPathComponent)
                        return atime < btime
                    }
                }
            }
        } catch let error {
            KFError.logError(error)
        }
    }
    
    func errorRequestToSend() -> (request: URLRequest, file: URL)? {
        KFLog.p("KFQueue errorRequestToSend")
        if self.errorFilesToSend != nil && self.errorFilesToSend!.count > 0 {
            guard let file = self.errorFilesToSend?.first else {
                return nil
            }
            do {
                let data = try Data(contentsOf: file)
                let request = NSKeyedUnarchiver.unarchiveObject(with: data) as! URLRequest
                return (request, file)
            } catch let error {
                KFError.logError(error)
            }
        }
        return nil
    }
    
    func loadRequestsToSend() -> Bool {
        KFLog.p("KFQueue loadRequestsToSend")
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
                KFError.logError(error)
            }
        }
        return false
    }
    
    func sendNextRequest() {
        KFLog.p("KFQueue sendNextRequest")
        self.errorOnLastSend = false
        if isReadyToSend() {
            guard let request = self.requestsToSend?.first else {
                KFError.logErrorMessage("sendNextRequest: Expected to find a request in the queue but it is empty.")
                return
            }
            self.requester.postRequest(request, filename: self.currentFile!)
        }
    }
    
    func sendNextErrorRequest() {
        KFLog.p("KFQueue sendNextErrorRequest")
        if isReadyToSend() {
            guard let (request, file) = errorRequestToSend() else {
                return
            }
            self.requester.postRequest(request, filename: file)
        }
    }
    
    @objc func didReceivePostSuccess(notification: Notification) {
        KFLog.p("KFQueue didReceivePostSuccess")
        if let info = notification.userInfo as? Dictionary<String, Any> {
            guard let filename = info["filename"] as? URL else {
                KFError.logErrorMessage("Post success notification is missing filename.")
                return
            }
            
            if filename.pathExtension == "errdata" {
                removeCurrentErrorSendRequestAndSendNext(filename)
            } else {
                if self.currentFile == filename {
                    removeCurrentSendRequestAndSendNext()
                } else {
                    KFError.logErrorMessage("didReceivePostSuccess: Filenames do not match.")
                }
            }
        }
    }
    
    @objc func didReceivePostError(notification: Notification) {
        KFLog.p("KFQueue didReceivePostError")
        
        if let info = notification.userInfo as? Dictionary<String, Any> {
            guard let filename = info["filename"] as? URL else {
                KFError.logErrorMessage("Post error notification is missing filename.")
                return
            }
            guard var request = info["request"] as? URLRequest else {
                KFError.logErrorMessage("Post error notification is missing request.")
                return
            }
            
            let isOldError = filename.pathExtension == "errdata"
            if isOldError {
                if errorFilesToSend?.first != filename {
                    KFError.logErrorMessage("didReceivePostError oldError: Filenames do not match.")
                    return
                }
            } else {
                if self.currentFile != filename {
                    KFError.logErrorMessage("didReceivePostError: Filenames do not match.")
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
                    KFError.logErrorMessage("Could not convert value of requestAttemptCount to int.  value = " + requestAttemptCountStr!)
                }
                requestAttemptCount = requestAttemptCount! + 1
                request.setValue(String(describing: requestAttemptCount!), forHTTPHeaderField: "requestAttemptCount")
            }
                    
            if isOldError {
                do {
                    let data = NSKeyedArchiver.archivedData(withRootObject: request)
                    try data.write(to: filename, options: [NSData.WritingOptions.atomic])
                } catch let error {
                    KFError.logError(error)
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
                        KFError.logError(error)
                    }
                            
                    //Make sure this flag is set last to prevent multi-threading conflicts
                    self.errorOnLastSend = true
                }
            }
        
        }
    }
    
    func removeCurrentSendRequestAndSendNext() {
        KFLog.p("KFQueue removeCurrentSendRequestAndSendNext")
        self.requestsToSend!.remove(at: 0)
        if self.requestsToSend!.count == 0 {
            self.filesToSend!.remove(at: 0)
            do {
                try FileManager.default.removeItem(at: self.currentFile!)
                self.currentFile = nil
            } catch let error {
                KFError.logError(error)
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
                KFError.logError(error)
            }
            sendNextRequest()
        }
    }
    
    func removeCurrentErrorSendRequestAndSendNext(_ filename: URL) {
        KFLog.p("KFQueue removeCurrentErrorSendRequestAndSendNext")
        if self.errorFilesToSend != nil && self.errorFilesToSend![0] == filename {
            self.errorFilesToSend!.remove(at: 0)
        }
        
        do {
            try FileManager.default.removeItem(at: filename)
        } catch let error {
            KFError.logError(error)
        }
        
        sendNextErrorRequest()
    }
    
    func skipCurrentErrorSendRequestAndSendNext(_ filename: URL) {
        KFLog.p("KFQueue skipCurrentErrorSendRequestAndSendNext")
        if self.errorFilesToSend != nil && self.errorFilesToSend![0] == filename {
            self.errorFilesToSend!.remove(at: 0)
        }
        
        sendNextErrorRequest()
    }
    
    func startSending() {
        KFLog.p("KFQueue startSending")
        if isReadyToSend() {
            loadFilesToSend()
            if loadRequestsToSend() {
                sendNextRequest()
            }
        }
    }
    
    func startSendingErrors() {
        guard let lastAttemptDate = KFUserDefaults.lastAttemptToSendErrorQueue() else {
            return
        }
        if fabs(lastAttemptDate.timeIntervalSinceNow) > KFQueue.kTimeToWaitBeforeSendingMessagesWithErrors {
            KFUserDefaults.setLastAttemptToSendErrorQueue(Date())
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
        
        let path = documentsDir.appendingPathComponent("Application Support", isDirectory:true).appendingPathComponent(KFDevice.appBundleId(), isDirectory:true).appendingPathComponent("Kitemetrics", isDirectory:true).appendingPathComponent(subdirectory, isDirectory:true)
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: path.absoluteString) {
            do {
                try fileManager.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                KFError.logError(error)
            }
        }
        
        return path
    }
    
    func isReadyToSend() -> Bool {
        if self.isApiKeySet == false {
            if Kitemetrics.shared.apiKey == "" {
                KFError.logErrorMessage("Kitemetrics needs API Key, or API Key not yet loaded", sendToServer: false)
            } else {
                self.isApiKeySet = true
            }
        }
        
        if self.isApiKeySet && self.reachability != nil && self.reachability!.connection != .unavailable {
            if Kitemetrics.shared.currentBackoffValue < Kitemetrics.shared.currentBackoffMultiplier {
                Kitemetrics.shared.currentBackoffValue = Kitemetrics.shared.currentBackoffValue + 1
                KFLog.p("Connection timeout, skip")
                return false
            }
            
            return true
        }
        
        return false
    }
    
}
