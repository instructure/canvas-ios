//
//  NSObject+Bundle.swift
//  Calendar
//
//  Created by Brandon Pluim on 3/24/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation

public extension NSObject {
    class var bundle: NSBundle? {
        return NSBundle(forClass: self.classForCoder())
    }
}