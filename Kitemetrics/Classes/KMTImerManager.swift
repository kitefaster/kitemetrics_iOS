//
//  KMSession.swift
//  Kitemetrics
//
//  Created by Kitemetrics on 11/7/16.
//  Copyright © 2021 Kitemetrics. All rights reserved.
//

import Foundation


class KMTimerManager {
    
    var timer: Timer?
    static var kTimerInterval: TimeInterval = 10 //60
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willTerminate), name: UIApplication.willTerminateNotification, object: nil)
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
        if self.timer == nil {
            self.timer = Timer.scheduledTimer(timeInterval: KMTimerManager.kTimerInterval, target: self, selector: #selector(self.perfromTimerActions), userInfo: nil, repeats: true)
            self.timer!.tolerance = KMTimerManager.kTimerInterval * 0.3
        }
    }
    
    func stopTimer() {
        if (self.timer != nil) {
            self.timer!.invalidate()
            self.timer = nil
        }
    }
    
    @objc func perfromTimerActions() {
        KMLog.p("timer fired")
        KMUserDefaults.setCloseTime(Date())
        Kitemetrics.shared.queue.saveQueue()
    }
    
    func performForegroundActions() {
        KMLog.p("startTimer")
        Kitemetrics.shared.sessionManager.open()
        startTimer()
    }
    
    func performBackgroundActions() {
        KMLog.p("stopTimer")
        stopTimer()
        Kitemetrics.shared.queue.saveQueue()
        KMUserDefaults.setCloseTime(Date())
    }
    
    func fireTimerManually() {
        stopTimer()
        perfromTimerActions()
        startTimer()
    }
    
}
