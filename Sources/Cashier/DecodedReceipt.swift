//
//  DecodedReceipt.swift
//  Cashier
//
//  Created by August Heegaard on 15/12/2016.
//
//

import Foundation

public struct DecodedReceipt {
    
    /// The raw JSON response received from the receipt validation service.
    /// More details about the contents are available at:
    /// https://developer.apple.com/library/content/releasenotes/General/ValidateAppStoreReceipt/Chapters/ReceiptFields.html#//apple_ref/doc/uid/TP40010573-CH106-SW1
    public let jsonResponse: [String:Any]
    
    /// MARK: Receipt fields
    
    /// The app’s bundle identifier.
    /// This corresponds to the value of CFBundleIdentifier in the Info.plist file.
    public let bundleIdentifier: String
    
    /// The app’s version number.
    /// This corresponds to the value of CFBundleVersion (in iOS) or CFBundleShortVersionString (in OS X) in the Info.plist.
    public let appVersion: String
    
    /// The version of the app that was originally purchased.
    /// This corresponds to the value of CFBundleVersion (in iOS) or CFBundleShortVersionString (in OS X) in the Info.plist file when the purchase was originally made.
    ///
    /// In the sandbox environment, the value of this field is always “1.0”.
    public let originalAppVersion: String
    
    /// The date when the app receipt was created.
    /// When validating a receipt, use this date to validate the receipt’s signature.
    public let creationDate: Date
    
    /// The date that the app receipt expires.
    /// This key is present only for apps purchased through the Volume Purchase Program. If this key is not present, the receipt does not expire.
    ///
    /// When validating a receipt, compare this date to the current date to determine whether the receipt is expired. Do not try to use this date to calculate any other information, such as the time remaining before expiration.
    public let expirationDate: Date?
    
    /// The receipt for an in-app purchase.
    ///
    /// The in-app purchase receipt for a consumable product is added to the receipt when the purchase is made. It is kept in the receipt until your app finishes that transaction. After that point, it is removed from the receipt the next time the receipt is updated—for example, when the user makes another purchase or if your app explicitly refreshes the receipt.
    ///
    /// The in-app purchase receipt for a non-consumable product, auto-renewable subscription, non-renewing subscription, or free subscription remains in the receipt indefinitely.
    public let inAppReceipts: [InAppReceipt]
    
    // MARK: Init
    internal init(json: [String:Any]) throws {
        
        self.jsonResponse = json
        
        guard
            let bundleIdentifier = json["bundle_id"] as? String,
            let appVersion = json["application_version"] as? String,
            let originalAppVersion = json["original_application_version"] as? String,
            
            let creationDateString = json["receipt_creation_date"] as? String,
            let creationDateMs = Double(creationDateString)
            else {
                throw Cashier.CashierError.jsonMissingFields
        }
        
        self.bundleIdentifier = bundleIdentifier
        self.appVersion = appVersion
        self.originalAppVersion = originalAppVersion
        self.creationDate = Date(timeIntervalSince1970: creationDateMs / 1000)
        
        // Apple's docs state that the JSON field name is "expiration_date", but they
        // also state that the field name of creation date is "creation_date". This is not
        // the case as this field has "receipt_" prepended to its name. This leads me to believe
        // that the same thing is the case here. The field is only present on volume purchases, so
        // I have no way of testing it right now.
        // TODO: Use the correct field name.
        self.expirationDate = Date.fromMillisecondValue(json["receipt_expiration_date"]) ?? Date.fromMillisecondValue(json["expiration_date"])
        
        // Parse the array of in-app purchase receipts.
        var inAppReceipts = [InAppReceipt]()
        
        if let inAppArray = json["in_app"] as? [[String:Any]] {
            
            for dictionary in inAppArray {
                
                let inAppReceipt = try InAppReceipt(json: dictionary)
                inAppReceipts.append(inAppReceipt)
                
            }
            
        }
        
        self.inAppReceipts = inAppReceipts
        
    }
    
}
