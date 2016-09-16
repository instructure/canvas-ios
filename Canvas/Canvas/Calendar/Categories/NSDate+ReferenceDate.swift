//
//  NSDate+ReferenceDate.swift
//  iCanvas
//
//  Created by Brandon Pluim on 6/4/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation


public extension NSDate {
    
    func daysSince1970(calendar: NSCalendar)-> Int{
        let originationDate = NSDate(timeIntervalSince1970: 0).startOfDay(calendar)

        let components = calendar.components(.Day, fromDate: originationDate, toDate: self, options: NSCalendarOptions())
        return components.day
    }
}