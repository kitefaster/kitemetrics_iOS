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
            self.timer = Timer.scheduledTimer(timeInterval: KFTimerManager.kTimerInterval, target: self, selector: #selector(self.perfromTimerActions), userInfo: nil, repeats: true)
            self.timer!.tolerance = KFTimerManager.kTimerInterval * 0.3
        }
    }
    
    func stopTimer() {
        if (self.timer != nil) {
            self.timer!.invalidate()
            self.timer = nil
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
    
    func fireTimerManually() {
        stopTimer()
        perfromTimerActions()
        startTimer()
    }
    
}
