//
//  String+SoLazy.swift
//  iCanvas
//
//  Created by Ben Kraus on 6/1/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation

public extension String {
    public func toNSNumberWrappingInt64() -> NSNumber {
        return NSNumber(longLong: (self as NSString).longLongValue)
    }
    
    public func toInt64() -> Int64 {
        return self.toNSNumberWrappingInt64().longLongValue
    }

    public func isValidEmail() -> Bool {
        
        let range = NSRange(location: 0, length: self.characters.count)
        if let detector = try? NSDataDetector(types: NSTextCheckingType.Link.rawValue),
            let match = detector.firstMatchInString(self, options: NSMatchingOptions.Anchored, range: range),
            let scheme = match.URL?.scheme {
            return scheme == "mailto"
        }
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(self)
    }
}
