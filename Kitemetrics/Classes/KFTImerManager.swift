//
//  KFSession.swift
//  Pods
//
//  Created by Kitefaster on 11/7/16.
//  Copyright © 2017 Kitefaster, LLC. All rights reserved.
//

import Foundation


class KFTimerManager {
    
    var timer: Timer?
    static var kTimerInterval: TimeInterval = 10 //60
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willTerminate), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
    }
    
    deinit {
        performBackgroundActions()
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func didEnterBackground() {
        performBackgroundActions()
    }
    
    @objc func willEnterForeground() {
        performForegroundActions()
    }
    
    @objc func willResignActive() {
        performBackgroundActions()
    }
    
    @objc func didBecomeActive() {
        performForegroundActions()
    }
    
    @objc func willTerminate() {
        performBackgroundActions()
    }
    
    func startTimer() {
        DispatchQueue.main.async {
            if self.timer == nil {
                self.timer = Timer.scheduledTimer(timeInterval: KFTimerManager.kTimerInterval, target: self, selector: #selector(self.perfromTimerActions), userInfo: nil, repeats: true)
                self.timer!.tolerance = KFTimerManager.kTimerInterval * 0.3
            }
        }
    }
    
    func stopTimer() {
        DispatchQueue.main.async {
            if (self.timer != nil) {
                self.timer!.invalidate()
                self.timer = nil
            }
        }
    }
    
    @objc func perfromTimerActions() {
        KFLog.p("timer fired")
        KFUserDefaults.setCloseTime(Date())
        Kitemetrics.shared.queue.saveQueue()
    }
    
    func performForegroundActions() {
        KFLog.p("startTimer")
        Kitemetrics.shared.sessionManager.open()
        startTimer()
    }
    
    func performBackgroundActions() {
        KFLog.p("stopTimer")
        stopTimer()
        Kitemetrics.shared.queue.saveQueue()
        KFUserDefaults.setCloseTime(Date())
    }
    
}
