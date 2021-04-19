//
//  KMAttribution.swift
//  Kitemetrics
//
//  Created by Kitemetrics on 1/16/21.
//  Copyright © 2021 Kitemetrics. All rights reserved.

import Foundation

public struct KMAttributionDetails {
    var attribution: Bool = false
    var orgName: String = ""
    var orgId: String = ""
    var campaignName: String = ""
    var campaignId: String = ""
    var purchaseDate: String = ""
    var conversionDate: String = ""
    var conversionType: String = ""
    var clickDate: String = ""
    var adGroupName: String = ""
    var adGroupId: String = ""
    var countryOrRegion: String = ""
    var keyword: String = ""
    var keywordId: String = ""
    var keywordMatchType: String = ""
    var creativeSetId: String = ""
    var createiveSetName: String = ""
    var lineItemName: String = ""
    var lineItemId: String = ""
}

class KMAttribution {
    
    var attributionDetails: KMAttributionDetails? = nil
    
    init() {
        _ = bind()
    }
    
    public func bind() -> KMAttributionDetails? {
        
        guard let dictionaryWrapper: [String : NSObject] = KMUserDefaults.attribution() else {
            return nil
        }
        
        guard let dictionary: [String : Any] = dictionaryWrapper["Version3.1"] as? [String : Any] else {
            return nil
        }
        
        var details = KMAttributionDetails()
        
        if let attribution = dictionary["iad-attribution"] {
            details.attribution = attribution as? Bool ?? false
            details.attribution = attribution as? Bool ?? false
        }
        
        if let orgName = dictionary["iad-org-name"] {
            details.orgName = orgName as? String ?? ""
        }
        
        if let orgId = dictionary["iad-org-id"] {
            details.orgId = orgId as? String ?? ""
        }
        
        if let campaignName = dictionary["iad-campaign-name"] {
            details.campaignName = campaignName as? String ?? ""
        }
        
        if let campaignId = dictionary["iad-campaign-id"] {
            details.campaignId = campaignId as? String ?? ""
        }
        
        if let purchaseDate = dictionary["iad-purchase-date"] {
            details.purchaseDate = purchaseDate as? String ?? ""
        }
        
        if let conversionDate = dictionary["iad-conversion-date"] {
            details.conversionDate = conversionDate as? String ?? ""
        }
        
        if let conversionType = dictionary["iad-conversion-type"] {
            details.conversionType = conversionType as? String ?? ""
        }
        
        if let clickDate = dictionary["iad-click-date"] {
            details.clickDate = clickDate as? String ?? ""
        }
        
        if let orgName = dictionary["iad-org-name"] {
            details.orgName = orgName as? String ?? ""
        }
        
        if let adGroupId = dictionary["iad-adgroup-id"] {
            details.adGroupId = adGroupId as? String ?? ""
        }
        
        if let adGroupName = dictionary["iad-adgroup-name"] {
            details.adGroupName = adGroupName as? String ?? ""
        }
        
        if let countryOrRegion = dictionary["iad-country-or-region"] {
            details.countryOrRegion = countryOrRegion as? String ?? ""
        }
        
        if let keyword = dictionary["iad-keyword"] {
            details.keyword = keyword as? String ?? ""
        }
        
        if let keywordId = dictionary["iad-keyword-id"] {
            details.keywordId = keywordId as? String ?? ""
        }
        
        if let keywordMatchType = dictionary["iad-keyword-matchtype"] {
            details.keywordMatchType = keywordMatchType as? String ?? ""
        }
        
        if let creativeSetId = dictionary["iad-creativeset-id"] {
            details.creativeSetId = creativeSetId as? String ?? ""
        }
        
        if let createiveSetName = dictionary["iad-creativeset-name"] {
            details.createiveSetName = createiveSetName as? String ?? ""
        }
        
        self.attributionDetails = details
        return details
    }
    
}
