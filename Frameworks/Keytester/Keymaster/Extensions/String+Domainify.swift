//
//  String+Domainify.swift
//  Keymaster
//
//  Created by Brandon Pluim on 1/18/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation

// ---------------------------------------------
// MARK: - Domainify
// ---------------------------------------------
extension String {
    mutating func domainify() {
        stripURLScheme()
        removeSlashes()
        removeWhitespace()
        addInstructureDotComIfNeeded()
    }
    
    mutating func stripURLScheme() {
        let schemes = ["http://", "https://"]
        for scheme in schemes {
            if self.hasPrefix(scheme) {
                self = (self as NSString).substringFromIndex(scheme.characters.count)
            }
        }
    }
    
    mutating func removeSlashes() {
        self = self.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "/"))
    }

    mutating func removeWhitespace() {
        self = self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    mutating func addInstructureDotComIfNeeded() {
        if self.rangeOfString(":") == nil && self.rangeOfString(".") == nil {
            self += ".instructure.com"
        }
    }

    mutating func addURLScheme() {
        self = "https://\(self)"
    }
}