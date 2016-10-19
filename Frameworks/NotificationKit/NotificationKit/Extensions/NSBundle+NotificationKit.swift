//
//  NSBundle+NotificationKit.swift
//  NotificationKit
//
//  Created by Layne Moseley on 10/14/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation

extension NSBundle {
    static func notificationKit() -> NSBundle {
        return NSBundle(identifier: "com.instructure.NotificationKit")!
    }
}
