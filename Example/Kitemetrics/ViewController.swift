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
        
        let scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor.white
        self.view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            (make) -> Void in
            make.edges.equalTo(self.view)
        }
        
        let eventButton = UIButton(type: .custom)
        eventButton.backgroundColor = UIColor.black
        eventButton.setTitle("Create Event", for: .normal)
        eventButton.addTarget(self, action: #selector(createEvent), for: .touchUpInside)
        scrollView.addSubview(eventButton)
        eventButton.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(scrollView).offset(20)
            make.centerX.equalTo(self.view)
            make.width.equalTo(400)
            make.height.equalTo(44)
        }
        
        let eventSignUpButton = UIButton(type: .custom)
        eventSignUpButton.backgroundColor = UIColor.black
        eventSignUpButton.setTitle("Create Sign Up Event", for: .normal)
        eventSignUpButton.addTarget(self, action: #selector(createEventSignUp), for: .touchUpInside)
        scrollView.addSubview(eventSignUpButton)
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
        scrollView.addSubview(eventInviteButton)
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
        scrollView.addSubview(eventRedeemInviteButton)
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
        scrollView.addSubview(errorButton)
        errorButton.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(eventRedeemInviteButton.snp.bottom).offset(20)
            make.centerX.equalTo(self.view)
            make.width.equalTo(400)
            make.height.equalTo(44)
        }
        
        let addToCartButton = UIButton(type: .custom)
        addToCartButton.backgroundColor = UIColor.black
        addToCartButton.setTitle("Create Add to Cart", for: .normal)
        addToCartButton.addTarget(self, action: #selector(createAddToCart), for: .touchUpInside)
        scrollView.addSubview(addToCartButton)
        addToCartButton.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(errorButton.snp.bottom).offset(20)
            make.centerX.equalTo(self.view)
            make.width.equalTo(400)
            make.height.equalTo(44)
        }
        
        let purchaseButton = UIButton(type: .custom)
        purchaseButton.backgroundColor = UIColor.black
        purchaseButton.setTitle("Create Purchase", for: .normal)
        purchaseButton.addTarget(self, action: #selector(createPurchase), for: .touchUpInside)
        scrollView.addSubview(purchaseButton)
        purchaseButton.snp.makeConstraints {
            (make) -> Void in
            make.top.equalTo(addToCartButton.snp.bottom).offset(20)
            make.centerX.equalTo(self.view)
            make.width.equalTo(400)
            make.height.equalTo(44)
            make.bottom.equalTo(scrollView)
        }
        
    }
    
    @objc func createEvent() {
        Kitemetrics.shared.logEvent("Test Event")
    }
    
    @objc func createEventSignUp() {
        Kitemetrics.shared.logSignUp(method: "email", userIdentifier: "012345abc")
    }
    
    @objc func createEventInvite() {
        Kitemetrics.shared.logInvite(method: "Test Invite Method", code: "Test Invite Code 0001")
    }
    
    @objc func createEventRedeemInvite() {
        Kitemetrics.shared.logRedeemInvite(code: "Test Invite Code 0001")
    }
    
    @objc func createError() {
        Kitemetrics.shared.logError("Test Error")
    }
    
    @objc func createAddToCart() {
        //If you have the SKProduct from an In-App Purchase you can use the below
        //Kitemetrics.shared.logInAppPurchase(SKProduct, quantity: Int, purchaseType: KFPurchaseType)
        //else if the SKProduct is unavailble or this is an eCommerce transaction you can pass the productIdentifier, price and currency code manually
        Kitemetrics.shared.logAddToCart(productIdentifier: "com.kitefaster.demo.Kitemetrics-Example.TestPurchase1", price: Decimal(0.99), currencyCode: "USD", quantity: 1, purchaseType: .appleInAppConsumable)
    }
    
    @objc func createPurchase() {
        //If you have the SKProduct from an In-App Purchase you can use the below
        //Kitemetrics.shared.logInAppPurchase(SKProduct, quantity: Int, purchaseType: KFPurchaseType)
        //else if the SKProduct is unavailble or this is an eCommerce transaction you can pass the productIdentifier, price and currency code manually
        Kitemetrics.shared.logPurchase(productIdentifier: "com.kitefaster.demo.Kitemetrics-Example.TestPurchase1", price: Decimal(0.99), currencyCode: "USD", quantity: 1, purchaseType: .appleInAppConsumable)
    }

}

