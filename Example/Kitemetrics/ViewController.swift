//
//  ViewController.swift
//  Kitemetrics
//
//  Created by Kitefaster on 10/14/2016.
//  Copyright © 2017 Kitefaster. All rights reserved.
//

import UIKit
import SnapKit
import Kitemetrics

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        let eventButton = UIButton(type: .custom)
        eventButton.backgroundColor = UIColor.black
        eventButton.setTitle("Create Event", for: .normal)
        eventButton.addTarget(self, action: #selector(createEvent), for: .touchUpInside)
        self.view.addSubview(eventButton)
        eventButton.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(self.view).offset(20)
            make.centerX.equalTo(self.view)
            make.width.equalTo(400)
            make.height.equalTo(44)
        }
        
        let eventSignUpButton = UIButton(type: .custom)
        eventSignUpButton.backgroundColor = UIColor.black
        eventSignUpButton.setTitle("Create Sign Up Event", for: .normal)
        eventSignUpButton.addTarget(self, action: #selector(createEventSignUp), for: .touchUpInside)
        self.view.addSubview(eventSignUpButton)
        eventSignUpButton.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(eventButton.snp.bottom).offset(20)
            make.centerX.equalTo(self.view)
            make.width.equalTo(400)
            make.height.equalTo(44)
        }
        
        let eventInviteButton = UIButton(type: .custom)
        eventInviteButton.backgroundColor = UIColor.black
        eventInviteButton.setTitle("Create Invite Event", for: .normal)
        eventInviteButton.addTarget(self, action: #selector(createEventInvite), for: .touchUpInside)
        self.view.addSubview(eventInviteButton)
        eventInviteButton.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(eventSignUpButton.snp.bottom).offset(20)
            make.centerX.equalTo(self.view)
            make.width.equalTo(400)
            make.height.equalTo(44)
        }
        
        let eventRedeemInviteButton = UIButton(type: .custom)
        eventRedeemInviteButton.backgroundColor = UIColor.black
        eventRedeemInviteButton.setTitle("Create Redeem Invite Event", for: .normal)
        eventRedeemInviteButton.addTarget(self, action: #selector(createEventRedeemInvite), for: .touchUpInside)
        self.view.addSubview(eventRedeemInviteButton)
        eventRedeemInviteButton.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(eventInviteButton.snp.bottom).offset(20)
            make.centerX.equalTo(self.view)
            make.width.equalTo(400)
            make.height.equalTo(44)
        }
        
        let errorButton = UIButton(type: .custom)
        errorButton.backgroundColor = UIColor.black
        errorButton.setTitle("Create Error", for: .normal)
        errorButton.addTarget(self, action: #selector(createError), for: .touchUpInside)
        self.view.addSubview(errorButton)
        errorButton.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(eventRedeemInviteButton.snp.bottom).offset(20)
            make.centerX.equalTo(self.view)
            make.width.equalTo(400)
            make.height.equalTo(44)
        }
        
    }
    
    func createEvent() {
        Kitemetrics.shared.logEvent("Test Event")
    }
    
    func createEventSignUp() {
        Kitemetrics.shared.logSignUp(method: "email", userIdentifier: "012345abc")
    }
    
    func createEventInvite() {
        Kitemetrics.shared.logInvite(method: "Test Invite Method", code: "Test Invite Code 0001")
    }
    
    func createEventRedeemInvite() {
        Kitemetrics.shared.logRedeemInvite(code: "Test Invite Code 0001")
    }
    
    func createError() {
        Kitemetrics.shared.logError("Test Error")
    }

}

