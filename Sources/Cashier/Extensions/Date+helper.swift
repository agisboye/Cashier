//
//  Date+helper.swift
//  Cashier
//
//  Created by August Heegaard on 15/12/2016.
//
//

import Foundation

// Internal helper method
internal extension Date {
    
    static func fromMillisecondValue(_ value: Any?) -> Date? {
        
        if
            let millisecondsString = value as? String,
            let milliseconds = Double(millisecondsString) {
            return Date(timeIntervalSince1970: milliseconds / 1000)
        } else {
            return nil
        }
        
    }
    
}
