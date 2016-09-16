//
//  CalendarDate.swift
//  Calendar
//
//  Created by Brandon Pluim on 3/6/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation

public struct CalendarDate: Equatable {
    var year = 0
    var month = 0
    var day = 0
    
    public mutating func populate(date: NSDate, calendar: NSCalendar) {
        let components = calendar.components([.Year, .Month, .Day], fromDate: date)
        year = components.year
        month = components.month
        day = components.day
    }
    
    public func date(calendar: NSCalendar) -> NSDate {
        let components = NSDateComponents()
        components.day = day
        components.month = month
        components.year = year
        return calendar.dateFromComponents(components)!
    }
}

public func == (calDate1: CalendarDate, calDate2: CalendarDate) -> Bool {
    return calDate1.year == calDate2.year && calDate1.month == calDate2.month && calDate1.day == calDate2.day
}

public func > (calDate1: CalendarDate, calDate2: CalendarDate) -> Bool {
    if calDate1.year > calDate2.year {
        return true
    } else if calDate1.year < calDate2.year {
        return false
    }
    
    if calDate1.month > calDate2.month {
        return true
    } else if calDate1.month < calDate2.month {
        return false
    }
    
    if calDate1.day > calDate2.day {
        return true
    }
    
    return false
}

public func < (calDate1: CalendarDate, calDate2: CalendarDate) -> Bool {
    return !(calDate1 > calDate2)
}