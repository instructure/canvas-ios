//
//  NSBundle+SoSupportive.swift
//  SoSupportive
//
//  Created by Layne Moseley on 10/10/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation

extension NSBundle {
    static func soSupportive() -> NSBundle {
        return NSBundle(identifier: "com.instructure.SoSupportive")!
    }
}