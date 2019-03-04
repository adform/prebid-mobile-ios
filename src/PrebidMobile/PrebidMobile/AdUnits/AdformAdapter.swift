//
//  AdformAdapter.swift
//  PrebidMobile
//
//  Created by Vladas Drejeris on 04/03/2019.
//  Copyright © 2019 AppNexus. All rights reserved.
//

import Foundation

/// This adapter provides integration for Adform Advertising SDK.
class AdformAdapter {

    // MARK: - Constants

    private let hbPrice = "hb_price"
    private let hbBidder = "hb_bidder"
    private let hbCacheId = "hb_cache_id"

    private var adformAdInlineName = "AFAdInline"
    private var adformAdHesionName = "AFAdHesion"
    private var adformAdInterstitialName = "AFAdInterstitial"
    private var adformAdOverlayName = "AFAdOverlay"

    private var pricePropertyName = "price"
    private var removeKeyValuesSelectorSignature = "removeValuesForKey:"
    private var removeCustomParameterSelectorSignature = "removeCustomParameterForKey:"
    private var addValueForKeySelectorSignature = "addValue:forKey:"
    private var addCustomParameterForKeySelectorSignature = "addCustomParameter:forKey:"

    // MARK: - HB logic

    /// Removes header bidding parameters from ad object, if passed in ad object is from Adform Advertising SDK.
    ///
    /// - Parameters:
    ///   - adObject: An ad object to remove parameters from.
    ///   - className: The class name of the ad object that is passed to the method.
    /// - Returns: Returns true if HB parameters were removed successfully, otherwise false.
    func removeHBKeywords(from adObject: AnyObject, with className: String) -> Bool {
        guard className.hasSuffix(adformAdInlineName)
            || className.hasSuffix(adformAdHesionName)
            || className.hasSuffix(adformAdInterstitialName)
            || className.hasSuffix(adformAdOverlayName) else {
            return false
        }

        // Clear price.
        adObject.setValue(0, forKey: pricePropertyName)

        // Clear bidder.
        let removeKeyValuesSelector = NSSelectorFromString(removeKeyValuesSelectorSignature)
        if adObject.responds(to: removeKeyValuesSelector) {
            _ = adObject.perform(removeKeyValuesSelector, with: hbBidder)
        }

        // Clear cache id.
        let removeCustomParametersSelector = NSSelectorFromString(removeCustomParameterSelectorSignature)
        if adObject.responds(to: removeCustomParametersSelector) {
            _ = adObject.perform(removeCustomParametersSelector, with: hbCacheId)
        }

        return true
    }

    /// Sets header bidding parameters to the ad object, if passed in ad object is from Adform Advertising SDK.
    ///
    /// - Parameters:
    ///   - adObject: An ad object to set parameters to.
    ///   - className: The class name of the ad object that is passed to the method.
    ///   - bidResponse: A bid response containing custom keywords with header bidding parameters.
    /// - Returns: Returns true if HB parameters were set successfully, otherwise false.
    func validateAndAttachKeywords(to adObject: AnyObject, with className: String, from bidResponse: BidResponse) -> Bool {
        let adObjectName = String(describing: adObject)

        guard adObjectName.hasSuffix(adformAdInlineName)
            || adObjectName.hasSuffix(adformAdHesionName)
            || adObjectName.hasSuffix(adformAdInterstitialName)
            || adObjectName.hasSuffix(adformAdOverlayName) else {
                return false
        }

        // Set price.
        if let price = bidResponse.customKeywords[hbPrice], let priceValue = Float(price) {
            adObject.setValue(priceValue, forKey: pricePropertyName)
        }

        // Set bidder.
        let addValueForKeySelector = NSSelectorFromString(addValueForKeySelectorSignature)
        if let value = bidResponse.customKeywords[hbBidder], adObject.responds(to: addValueForKeySelector) {
            _ = adObject.perform(addValueForKeySelector, with: value, with: hbBidder)
        }

        // Set cache id.
        let addCustomParameterForKeySelector = NSSelectorFromString(addCustomParameterForKeySelectorSignature)
        if let value = bidResponse.customKeywords[hbCacheId], adObject.responds(to: addCustomParameterForKeySelector) {
            _ = adObject.perform(addCustomParameterForKeySelector, with: value, with: hbCacheId)
        }

        return true
    }

}
