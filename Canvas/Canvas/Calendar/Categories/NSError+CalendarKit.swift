//
//  NSError+CalendarKit.swift
//  Calendar
//
//  Created by Brandon Pluim on 4/30/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation

extension NSError {
    class func calendarEventErrorWithMessage(message: String) -> NSError {
        return NSError(domain: "com.instructure.calendarkit", code: 0, userInfo: [NSLocalizedDescriptionKey: message])
    }
}
