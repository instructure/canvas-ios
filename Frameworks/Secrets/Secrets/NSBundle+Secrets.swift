//
//  NSBundle+Secrets.swift
//  Secrets
//
//  Created by Layne Moseley on 10/28/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation

extension NSBundle {
    static func secrets() -> NSBundle {
        return NSBundle(identifier: "com.instructure.Secrets")!
    }
}
