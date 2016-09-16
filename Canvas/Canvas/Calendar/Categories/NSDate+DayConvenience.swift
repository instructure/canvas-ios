//
//  NSDate+DayConvenience.swift
//  Calendar
//
//  Created by Brandon Pluim on 4/24/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation

public extension NSDate {
    func startOfDay(calendar: NSCalendar) -> NSDate {
        let components = calendar.components([.Year, .Month, .Day], fromDate:self)
        return calendar.dateFromComponents(components)!
    }
    
    func endOfDay(calendar: NSCalendar) -> NSDate {
        let components = NSDateComponents()
        components.day = 1
        components.nanosecond = -1
        return calendar.dateByAddingComponents(components, toDate: startOfDay(calendar), options: NSCalendarOptions())!
    }
}