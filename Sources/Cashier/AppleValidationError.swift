//
//  AppleValidationError.swift
//  Cashier
//
//  Created by August Heegaard on 15/12/2016.
//
//

/// https://developer.apple.com/library/content/releasenotes/General/ValidateAppStoreReceipt/Chapters/ValidateRemotely.html#//apple_ref/doc/uid/TP40010573-CH104-SW4
public enum AppleValidationError: Int, Error {
    
    /// The App Store could not read the JSON object you provided.
    case badJSON = 21000
    
    /// The data in the receipt-data property was malformed or missing.
    case malformedReceiptData = 21002
    
    /// The receipt could not be authenticated.
    case invalidReceipt = 21003
    
    /// The shared secret you provided does not match the shared secret on file for your account.
    /// Only returned for iOS 6 style transaction receipts for auto-renewable subscriptions.
    case incorrectSharedSecret = 21004
    
    /// The receipt server is not currently available.
    case serverUnavailable = 21005
    
    /// This receipt is valid but the subscription has expired. When this status code is returned to your server, the receipt data is also decoded and returned as part of the response.
    /// Only returned for iOS 6 style transaction receipts for auto-renewable subscriptions.
    case subscriptionExpired = 21006
    
    /// This receipt is from the test environment, but it was sent to the production environment for verification. Send it to the test environment instead.
    case testReceiptInProductionEnvironemnt = 21007
    
    /// This receipt is from the production environment, but it was sent to the test environment for verification. Send it to the production environment instead.
    case productionReceiptInTestEnvironment = 21008
    
}
