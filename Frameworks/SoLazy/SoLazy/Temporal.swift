//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import Foundation

private let _LongStyleDateFormatter: NSDateFormatter = {
    let format = NSDateFormatter()
    format.dateStyle = .LongStyle
    return format
}()

private let _MediumStyleDateTimeFormatter: NSDateFormatter = {
    let format = NSDateFormatter()
    format.dateStyle = .MediumStyle
    format.timeStyle = .MediumStyle
    return format
}()

private let _yyyyMMdd: NSDateFormatter = {
    let format = NSDateFormatter()
    format.dateFormat = "yyyyMMdd"
    return format
}()

private let _relativeShortDateAndTime: NSDateFormatter = {
    let format = NSDateFormatter()
    format.dateStyle = .ShortStyle
    format.timeStyle = .ShortStyle
    format.doesRelativeDateFormatting = true
    return format
}()

private let _relativeShortDate: NSDateFormatter = {
    let format = NSDateFormatter()
    format.dateStyle = .ShortStyle
    format.doesRelativeDateFormatting = true
    return format
}()

public extension NSDate {
    public var formattedDueDate: String {
        let plus1 = self + 1.minutesComponents
        let is1159 = !(plus1 ~= self)
        if is1159 {
            return NSDateFormatter.relativeShortDate.stringFromDate(self)
        } else {
            return NSDateFormatter.relativeShortDateAndTime.stringFromDate(self)
        }
    }
}

public extension NSDateFormatter {
    public static var LongStyleDateFormatter: NSDateFormatter { return _LongStyleDateFormatter }
    public static var MediumStyleDateTimeFormatter: NSDateFormatter { return _MediumStyleDateTimeFormatter }
    public static var yyyyMMdd: NSDateFormatter { return _yyyyMMdd }
    public static var relativeShortDateAndTime: NSDateFormatter { return _relativeShortDateAndTime }
    public static var relativeShortDate: NSDateFormatter { return _relativeShortDate }
}

public extension NSDateComponents {
    class func zero() -> NSDateComponents {
        let c = NSDateComponents()
        
        c.era = 0
        c.nanosecond = 0
        c.year = 0
        c.month = 0
        c.day = 0
        c.hour = 0
        c.minute = 0
        c.second = 0
        c.weekOfMonth = 0
        
        return c
    }
}

public extension Int {
    public var nanosecondsComponents: NSDateComponents {
        let c = NSDateComponents.zero()
        c.nanosecond = self
        return c
    }
    
    public var secondsComponents: NSDateComponents {
        let c = NSDateComponents.zero()
        c.second = self
        return c
    }
    
    public var minutesComponents: NSDateComponents {
        let c = NSDateComponents.zero()
        c.minute = self
        return c
    }
    
    public var hoursComponents: NSDateComponents {
        let c = NSDateComponents.zero()
        c.hour = self
        return c
    }
    
    public var daysComponents: NSDateComponents {
        let c = NSDateComponents.zero()
        c.day = self
        return c
    }
    
    public var weeksComponents: NSDateComponents {
        let c = NSDateComponents.zero()
        c.weekOfMonth = self
        return c
    }
    
    public var monthsComponents: NSDateComponents {
        let c = NSDateComponents.zero()
        c.month = self
        return c
    }
    
    public var yearsComponents: NSDateComponents {
        let c = NSDateComponents.zero()
        c.year = self
        return c
    }
}

public extension Int {
    public var minutes: NSTimeInterval {
        return NSTimeInterval(self*60)
    }
    
    public var hours: NSTimeInterval {
        return NSTimeInterval(minutes*60)
    }
    
    public var days: NSTimeInterval {
        return NSTimeInterval(hours*24)
    }
}

private let TemporalCalendar = NSCalendar.autoupdatingCurrentCalendar()


// equality

/**
 Same day as?
 */
public func ~=(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.isTheSameDayAsDate(rhs)
}


// ordering

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    let order = lhs.compare(rhs)
    return order == NSComparisonResult.OrderedAscending
}

public func <=(lhs: NSDate, rhs: NSDate) -> Bool {
    let order = lhs.compare(rhs)
    return order == .OrderedSame || order == .OrderedAscending
}

public func >=(lhs: NSDate, rhs: NSDate) -> Bool {
    let order = lhs.compare(rhs)
    return order == .OrderedSame || order == .OrderedDescending
}

public func >(lhs: NSDate, rhs: NSDate) -> Bool {
    let order = lhs.compare(rhs)
    return order == NSComparisonResult.OrderedDescending
}

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    let order = lhs.compare(rhs)
    return order == NSComparisonResult.OrderedSame
}

// addition


public func +(lhs: NSDate, rhs: NSDateComponents) -> NSDate {
    return TemporalCalendar.dateByAddingComponents(rhs, toDate: lhs, options:[])!
}

public func +(lhs: NSDateComponents, rhs: NSDate) -> NSDate {
    return TemporalCalendar.dateByAddingComponents(lhs, toDate: rhs, options: [])!
}

public func +(lhs: NSDate, rhs: NSTimeInterval) -> NSDate {
    return lhs.dateByAddingTimeInterval(rhs)
}

public func +(lhs: NSTimeInterval, rhs: NSDate) -> NSDate {
    return rhs.dateByAddingTimeInterval(lhs)
}

public func +(lhs: NSDateComponents, rhs: NSDateComponents) -> NSDateComponents {
    
    let sum = NSDateComponents.zero()
    
    sum.era = lhs.era + rhs.era
    sum.nanosecond = lhs.nanosecond + rhs.nanosecond
    sum.year = lhs.year + rhs.year
    sum.month = lhs.month + rhs.month
    sum.day = lhs.day + rhs.day
    sum.hour = lhs.hour + rhs.hour
    sum.minute = lhs.minute + rhs.minute
    sum.second = lhs.second + rhs.second
    
    return sum
}

public prefix func -(components: NSDateComponents) -> NSDateComponents {
    let c = NSDateComponents.zero()
    
    c.nanosecond = -components.nanosecond
    c.year = -components.year
    c.month = -components.month
    c.day = -components.day
    c.hour = -components.hour
    c.minute = -components.minute
    c.second = -components.second
    c.weekOfMonth = -components.weekOfMonth
    
    return c
}

public func -(lhs: NSDate, rhs: NSDateComponents) -> NSDate {
    return lhs + -rhs
}

extension NSDate: Comparable {}

public extension NSDate {
    public convenience init(year: Int, month: Int, day: Int) {
        let components = NSDateComponents()
        components.year = year
        components.month = month
        components.day = day
        let tx = TemporalCalendar.dateFromComponents(components)?.timeIntervalSinceReferenceDate
        self.init(timeIntervalSinceReferenceDate:tx!)
    }
    
    public var dateAtMidnight: NSDate {
        let components = TemporalCalendar.components([.Day, .Month, .Year], fromDate: self)
        return TemporalCalendar.dateFromComponents(components)!
    }
    
    public var dateOnSundayAtTheBeginningOfTheWeek: NSDate {
        let date = dateAtMidnight
        let component = TemporalCalendar.component(.Weekday, fromDate: self)
        return date - (component - 1).daysComponents
    }
    
    public func isTheSameDayAsDate(date: NSDate) -> Bool {
        let myComponents = TemporalCalendar.components([.Day, .Month, .Year], fromDate: self)
        let otherComponents = TemporalCalendar.components([.Day, .Month, .Year], fromDate: date)
        
        return myComponents.year == otherComponents.year && myComponents.month == otherComponents.month && myComponents.day == otherComponents.day
    }
    
    public var yyyyMMdd: String { return NSDateFormatter.yyyyMMdd.stringFromDate(self) }
}

// returns an array of days (00:00:00) (removes time component) from the start date to finish date inclusive
public func ...(lhs: NSDate, rhs: NSDate) -> [NSDate] {
    let start =  lhs.dateAtMidnight
    let end = rhs.dateAtMidnight
    
    if end < start {
        return []
    }
    
    let dayCount = TemporalCalendar.components(.Day, fromDate:start, toDate: end, options: []).day
    if dayCount <= 0 {
        return [start]
    }
    
    let range = 0...dayCount
    return range.map { i in
        start + i.days
    }
}

// returns an array of days (00:00:00) (removes time component) from the start date to finish date exclusive
public func ..<(lhs: NSDate, rhs: NSDate) -> [NSDate] {
    let start =  lhs.dateAtMidnight
    let end = rhs.dateAtMidnight

    if end < start {
        return []
    }

    let dayCount = TemporalCalendar.components(.Day, fromDate:start, toDate: end, options: []).day
    if dayCount <= 0 {
        return [start]
    }

    let range = 0..<dayCount
    return range.map { i in
        start + i.days
    }
}

public class Clock {
    static let sharedClock = Clock()

    var referenceDate = NSDate(timeIntervalSinceReferenceDate: 0)
    var referenceDateInterval: NSTimeInterval {
        get { return referenceDate.timeIntervalSinceReferenceDate }
        set { referenceDate = NSDate(timeIntervalSinceReferenceDate: newValue) }
    }

    public static func currentTime() -> NSDate {
        return NSDate(timeIntervalSinceNow: sharedClock.referenceDateInterval)
    }

    public static func timeTravel(to date: NSDate, @noescape block: ()->Void) {
        sharedClock.referenceDateInterval = date.timeIntervalSinceNow
        block()
        restoreTime()
    }

    static func restoreTime() {
        sharedClock.referenceDateInterval = 0
    }
}
