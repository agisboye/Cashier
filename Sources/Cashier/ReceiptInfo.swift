//
//  ReceiptInfo.swift
//  Cashier
//
//  Created by August Heegaard on 15/12/2016.
//
//

import Foundation

public struct ReceiptInfo {
    
    public let environment: Cashier.Environment
    
    public let receipt: DecodedReceipt
    
    /// Only returned for iOS 6 style transaction receipts for auto-renewable subscriptions. The base-64 encoded transaction receipt for the most recent renewal.
    public let latestReceipt: String?
    
    /// Only returned for iOS 6 style transaction receipts for auto-renewable subscriptions. The JSON representation of the receipt for the most recent renewal.
    public let latestReceiptInfo: DecodedReceipt?
    
    // MARK: Init
    internal init(json: [String:Any], environment: Cashier.Environment) throws {
        
        guard let receiptDict = json["receipt"] as? [String:Any] else {
            throw Cashier.CashierError.jsonMissingFields
        }
        
        self.environment = environment
        self.receipt = try DecodedReceipt(json: receiptDict)
        self.latestReceipt = json["latest_receipt"] as? String
        
        if let latestReceiptInfo = json["latest_receipt_info"] as? [String:Any] {
            let decoded = try DecodedReceipt(json: latestReceiptInfo)
            self.latestReceiptInfo = decoded
        } else {
            self.latestReceiptInfo = nil
        }
        
    }
    
}
