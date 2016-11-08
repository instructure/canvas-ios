//
//  NSBundle+SoThankfule.swift
//  SoThankful
//
//  Created by Layne Moseley on 11/7/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation

extension NSBundle {
    
    static func soThankfulBundle() -> NSBundle {
        return NSBundle(identifier: "com.instructure.SoThankful")!
    }
}
