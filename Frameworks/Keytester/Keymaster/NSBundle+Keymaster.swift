//
//  NSBundle+Keymaster.swift
//  Keytester
//
//  Created by Layne Moseley on 10/10/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation

extension NSBundle {
    static func keymaster() -> NSBundle {
        return NSBundle(identifier: "com.instructure.Keymaster")!
    }
}