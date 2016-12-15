
import Foundation

public enum ValidationResult {
    case decoded(ReceiptInfo)
    case raw([String:Any])
    case fail(Error)
}

public class Cashier {
    
    public enum Environment {
        case production
        case sandbox
        
        internal var url: URL {
            switch self {
            case .production:
                return URL(string: "https://buy.itunes.apple.com/verifyReceipt")!
            case .sandbox:
                return URL(string: "https://sandbox.itunes.apple.com/verifyReceipt")!
            }
        }

    }
    
    public let base64Receipt: String
    public let environment: Environment
    public let sharedSecret: String?
    
    fileprivate let urlSession: URLSession
    
    /// If validation fails because a sandbox receipt is being validated in a production environment or vice versa,
    /// the cashier will automatically retry the validation in the correct environment.
    /// Default is `true`.
    public var retryInCorrectEnvironment: Bool = true

    public init(base64Receipt: String, environment: Environment, sharedSecret: String?) {
        self.base64Receipt = base64Receipt
        self.environment = environment
        self.sharedSecret = sharedSecret
        
        let urlSessionConfig = URLSessionConfiguration()
        urlSessionConfig.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        urlSession = URLSession(configuration: urlSessionConfig)
        
    }

    /// - warning: The server may return both an error and also a decoded receipt. See
    public func validateReceipt(callback: @escaping ((ValidationResult) -> Void)) -> Void {
        
        // Prepare the request data.
        var requestContents = [
            "receipt-data": base64Receipt
        ]
        
        if let sharedSecret = self.sharedSecret {
            requestContents["password"] = sharedSecret
        }
        
        let requestData: Data
        
        do {
            requestData = try JSONSerialization.data(withJSONObject: requestContents, options: [])
        } catch {
            callback(.fail(CashierError.requestPreparationError))
            return
        }
        
        var request = URLRequest(url: environment.url)
        request.httpMethod = "POST"
        request.httpBody = requestData

        // Run the validation request.
        let task = urlSession.dataTask(with: request) { (data: Data?, urlResponse: URLResponse?, error: Error?) in
            
            // Handle client errors
            guard error == nil else {
                callback(.fail(CashierError.clientNetworkError(error!)))
                return
            }
            
            guard
                let data = data,
                !data.isEmpty
            else {
                callback(.fail(CashierError.emptyResponse))
                return
            }

            // Parse JSON response
            let json: [String:Any]

            do {
                
                guard let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else {
                    callback(.fail(CashierError.jsonParsingFailed))
                    return
                }
                
                json = dictionary
                
            } catch {
                callback(.fail(CashierError.jsonParsingFailed))
                return
            }
            
            // Check the response status code from Apple.
            guard let status = json["status"] as? Int else {
                callback(.fail(CashierError.jsonParsingFailed))
                return
            }
            
            let appleError = AppleValidationError(rawValue: status)
            
            // According to the Apple docs, the status is either 0 (indicating that the receipt is valid)
            // or an error code (all of which are implemented in `AppleValidationError`).
            // The subscription expired event is an exception to the rule, because receipt data is also returned with it.
            guard status == 0 || appleError == .subscriptionExpired else {
                
                let error: Error = appleError ?? CashierError.unknownResponseStatus
                
                // If the receipt was simply validated in the wrong environment (and the user allows)
                // we repeat the request in the other possible environment.
                // We make a bit of a dangerous assumption here, which is that the
                // receipt validation will never return a wrong environment error in both environments for the same receipt.
                // If the this happens, the application will bounce back and forth between the two environments,
                // making requests indefinitely.
                if appleError != nil && self.retryInCorrectEnvironment {
                    
                    if appleError == .testReceiptInProductionEnvironemnt && self.environment == .production {
                        
                        let newCashier = Cashier(base64Receipt: self.base64Receipt, environment: .sandbox, sharedSecret: self.sharedSecret)
                        newCashier.validateReceipt(callback: callback)
                        return
                        
                    } else if appleError == .testReceiptInProductionEnvironemnt && self.environment == .sandbox {
                        
                        let newCashier = Cashier(base64Receipt: self.base64Receipt, environment: .production, sharedSecret: self.sharedSecret)
                        newCashier.validateReceipt(callback: callback)
                        return
                        
                    }
                    
                }

                callback(.fail(error))
                return

            }

            do {
                let receiptInfo = try ReceiptInfo(json: json, environment: self.environment)
                callback(.decoded(receiptInfo))
            } catch {
                callback(.raw(json))
                return
            }

        }
        
        task.resume()

    }
    
}

extension Cashier {
    
    public enum CashierError: Error {
        case requestPreparationError
        case clientNetworkError(Error)
        case emptyResponse
        case jsonParsingFailed
        case jsonMissingFields
        case unknownResponseStatus
    }
    
}
