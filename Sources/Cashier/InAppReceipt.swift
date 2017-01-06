//
//  InAppReceipt.swift
//  Cashier
//
//  Created by August Heegaard on 15/12/2016.
//
//

import Foundation

/// Represents a receipt for an in-app purchase.
/// Depeneding on the type of in-app purchase, some of the fields are going to be `nil`.
/// [In-App Purchase Receipt Fields](https://developer.apple.com/library/content/releasenotes/General/ValidateAppStoreReceipt/Chapters/ReceiptFields.html#//apple_ref/doc/uid/TP40010573-CH106-SW12)
public struct InAppReceipt {
    
    /// The number of items purchased.
    /// This value corresponds to the quantity property of the [SKPayment](https://developer.apple.com/reference/storekit/skpayment) object stored in the transaction’s payment property.
    public let quantity: Int
    
    /// The product identifier of the item that was purchased.
    /// This value corresponds to the productIdentifier property of the [SKPayment](https://developer.apple.com/reference/storekit/skpayment) object stored in the transaction’s payment property.
    public let productIdentifier: String
    
    /// The transaction identifier of the item that was purchased.
    /// This value corresponds to the transaction’s [transactionIdentifier](https://developer.apple.com/reference/storekit/skpaymenttransaction/1411288-transactionidentifier) property.
    public let transactionIdentifier: String
    
    /// For a transaction that restores a previous transaction, the transaction identifier of the original transaction. Otherwise, identical to the transaction identifier.
    /// This value corresponds to the original transaction’s transactionIdentifier property.
    ///
    /// All receipts in a chain of renewals for an auto-renewable subscription have the same value for this field.
    public let originalTransactionIdentifier: String
    
    /// The date and time that the item was purchased.
    /// This value corresponds to the transaction’s transactionDate property.
    ///
    /// For a transaction that restores a previous transaction, the purchase date is the same as the original purchase date. Use Original Purchase Date to get the date of the original transaction.
    ///
    /// In an auto-renewable subscription receipt, this is always the date when the subscription was purchased or renewed, regardless of whether the transaction has been restored.
    public let purchaseDate: Date
    
    /// For a transaction that restores a previous transaction, the date of the original transaction.
    /// This value corresponds to the original transaction’s transactionDate property.
    ///
    /// In an auto-renewable subscription receipt, this indicates the beginning of the subscription period, even if the subscription has been renewed.
    public let originalPurchaseDate: Date
    
    /// The expiration date for the subscription, expressed as the number of milliseconds since January 1, 1970, 00:00:00 GMT.
    /// This key is only present for auto-renewable subscription receipts.
    public let subscriptionExpirationDate: Date?
    
    /// For a transaction that was canceled by Apple customer support, the time and date of the cancellation.
    /// Treat a canceled receipt the same as if no purchase had ever been made.
    public let cancellationDate: Date?
    
    /// This value is false by default unless the "is_trial_period" key is present
    /// in the receipt with a corresponding string value of "true".
    /// - warning: Not mentioned by Apple in their documentation.
    public let isTrialPeriod: Bool
    
    /// A string that the App Store uses to uniquely identify the application that created the transaction.
    /// If your server supports multiple applications, you can use this value to differentiate between them.
    ///
    /// Apps are assigned an identifier only in the production environment, so this key is not present for receipts created in the test environment.
    ///
    /// This field is not present for Mac apps.
    ///
    /// - seealso: Bundle Identifier.
    public let appItemId: String?
    
    /// An arbitrary number that uniquely identifies a revision of your application.
    /// This key is not present for receipts created in the test environment.
    public let externalVersionIdentifier: String?
    
    /// The primary key for identifying subscription purchases.
    public let webOrderLineItemId: String?
    
    // MARK: Init
    internal init(json: [String:Any]) throws {
        
        guard
            let quantityString = json["bundle_id"] as? String,
            let quantity = Int(quantityString),
            
            let productIdentifier = json["product_id"] as? String,
            let transactionIdentifier = json["transaction_id"] as? String,
            let originalTransactionIdentifier = json["original_transaction_id"] as? String,
            let purchaseDate = Date.fromMillisecondValue(json["purchase_date_ms"]),
            let originalPurchaseDate = Date.fromMillisecondValue(json["original_purchase_date_ms"])
            
            else {
                throw Cashier.CashierError.jsonMissingFields
        }
        
        self.quantity = quantity
        self.productIdentifier = productIdentifier
        self.transactionIdentifier = transactionIdentifier
        self.originalTransactionIdentifier = originalTransactionIdentifier
        self.purchaseDate = purchaseDate
        self.originalPurchaseDate = originalPurchaseDate
        
        // TODO: Determine correct field name
        self.subscriptionExpirationDate = Date.fromMillisecondValue(json["receipt_expires_date"]) ?? Date.fromMillisecondValue(json["expires_date"])
        self.cancellationDate = Date.fromMillisecondValue(json["receipt_cancellation_date"]) ?? Date.fromMillisecondValue(json["cancellation_date"])
        
        self.isTrialPeriod = (json["is_trial_period"] as? String) == "true"
        self.appItemId = json["app_item_id"] as? String
        self.externalVersionIdentifier = json["version_external_identifier"] as? String
        self.webOrderLineItemId = json["web_order_line_item_id"] as? String
        
    }
    
}
