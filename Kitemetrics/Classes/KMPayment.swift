//
//  KMPayment.swift
//  Kitemetrics
//
//  Created by Kitemetrics on 2/5/19.
//  Copyright © 2021 Kitemetrics. All rights reserved.
//


import Foundation
import StoreKit

class KMPayment: NSObject {
    
    var productsRequest: SKProductsRequest?
    lazy var transactions: [SKPaymentTransaction] = [SKPaymentTransaction]()
    lazy var productRequestRetry = 0
    
    override init() {
        super.init()
        
        SKPaymentQueue.default().add(self)
    }
}

extension KMPayment: SKPaymentTransactionObserver {
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if transaction.transactionState == .purchased {
                purchasedTransaction(transaction: transaction)
            }
        }
    }
    
    private func purchasedTransaction(transaction: SKPaymentTransaction) {
        let productIdentifier = transaction.payment.productIdentifier
        transactions.append(transaction)
        requestProduct(productIdentifier: productIdentifier)
        sendReceipt()
    }
    
    private func requestProduct(productIdentifier: String) {
        self.productsRequest = SKProductsRequest(productIdentifiers: [productIdentifier])
        self.productsRequest!.delegate = self
        self.productsRequest!.start()
    }
    
    private func sendReceipt() {
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL {
            if FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
                do {
                    let rawReceiptData = try Data(contentsOf: appStoreReceiptURL)
                    var request = URLRequest(url: URL(string: Kitemetrics.kReceiptsEndpoint)!)
                    request.httpBody = rawReceiptData
                    
                    let applicationId = KMUserDefaults.applicationId()
                    if applicationId > 0 {
                        request.addValue(String(applicationId), forHTTPHeaderField: "applicationId")
                    }
                    
                    let deviceId = KMUserDefaults.deviceId()
                    if deviceId > 0 {
                        request.addValue(String(deviceId), forHTTPHeaderField: "deviceId")
                    }
                    
                    let versionId = KMUserDefaults.versionId()
                    if versionId > 0 {
                        request.addValue(String(versionId), forHTTPHeaderField: "versionId")
                    }
                    
                    Kitemetrics.shared.queue.addItem(item: request)
                } catch {
                    // Do nothing
                }
            }
        }
    }
    
}

extension KMPayment: SKProductsRequestDelegate {
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products
        
        //Post transaction with product to server
        for transaction in transactions {
            let productIdentifier = transaction.payment.productIdentifier
            var product: SKProduct?
            for p in products {
                if p.productIdentifier == productIdentifier {
                    product = p
                    break
                }
            }
            if product != nil {
                var request = URLRequest(url: URL(string: Kitemetrics.kPaymentsEndpoint)!)
                
                guard let json = KMHelper.paymentJson(product: product!, transaction: transaction) else {
                    return
                }
                request.httpBody = json
                Kitemetrics.shared.queue.addItem(item: request)
            }
        }
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        //Try once more
        if productRequestRetry == 0 {
            for transaction in self.transactions {
                productRequestRetry = productRequestRetry + 1
                requestProduct(productIdentifier: transaction.payment.productIdentifier)
            }
        }
    }

}
