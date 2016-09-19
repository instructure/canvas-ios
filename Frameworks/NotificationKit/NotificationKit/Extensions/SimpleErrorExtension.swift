//
//  SimpleErrorExtension.swift
//  iCanvas
//
//  Created by Miles Wright on 7/30/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation

extension NSError {
    public class func simpleError(description: String, code: Int) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: NSLocalizedString(description, tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.NotificationKit")!, value: "", comment: "")]
        let error = NSError(domain: "com.instructure.canvas", code: code, userInfo: userInfo)
        return error
    }
}