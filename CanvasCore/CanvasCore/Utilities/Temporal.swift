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

private let _LongStyleDateFormatter: DateFormatter = {
    let format = DateFormatter()
    format.dateStyle = .long
    return format
}()

private let _MediumStyleDateTimeFormatter: DateFormatter = {
    let format = DateFormatter()
    format.dateStyle = .medium
    format.timeStyle = .medium
    return format
}()

private let _yyyyMMdd: DateFormatter = {
    let format = DateFormatter()
    format.dateFormat = "yyyyMMdd"
    return format
}()

private let _relativeShortDateAndTime: DateFormatter = {
    let format = DateFormatter()
    format.dateStyle = .short
    format.timeStyle = .short
    format.doesRelativeDateFormatting = true
    return format
}()

private let _relativeShortDate: DateFormatter = {
    let format = DateFormatter()
    format.dateStyle = .short
    format.doesRelativeDateFormatting = true
    return format
}()

public extension Date {
    public var formattedDueDate: String {
        let plus1 = self + 1.minutesComponents
        let is1159 = !(plus1 ~= self)
        if is1159 {
            return DateFormatter.relativeShortDate.string(from: self)
        } else {
            return DateFormatter.relativeShortDateAndTime.string(from: self)
        }
    }
}

public extension DateFormatter {
    public static var LongStyleDateFormatter: DateFormatter { return _LongStyleDateFormatter }
    public static var MediumStyleDateTimeFormatter: DateFormatter { return _MediumStyleDateTimeFormatter }
    public static var yyyyMMdd: DateFormatter { return _yyyyMMdd }
    public static var relativeShortDateAndTime: DateFormatter { return _relativeShortDateAndTime }
    public static var relativeShortDate: DateFormatter { return _relativeShortDate }
}

public extension DateComponents {
    static func zero() -> DateComponents {
        var c = DateComponents()
        
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
    public var nanosecondsComponents: DateComponents {
        var c = DateComponents.zero()
        c.nanosecond = self
        return c
    }
    
    public var secondsComponents: DateComponents {
        var c = DateComponents.zero()
        c.second = self
        return c
    }
    
    public var minutesComponents: DateComponents {
        var c = DateComponents.zero()
        c.minute = self
        return c
    }
    
    public var hoursComponents: DateComponents {
        var c = DateComponents.zero()
        c.hour = self
        return c
    }
    
    public var daysComponents: DateComponents {
        var c = DateComponents.zero()
        c.day = self
        return c
    }
    
    public var weeksComponents: DateComponents {
        var c = DateComponents.zero()
        c.weekOfMonth = self
        return c
    }
    
    public var monthsComponents: DateComponents {
        var c = DateComponents.zero()
        c.month = self
        return c
    }
    
    public var yearsComponents: DateComponents {
        var c = DateComponents.zero()
        c.year = self
        return c
    }
}

public extension Int {
    public var minutes: TimeInterval {
        return TimeInterval(self*60)
    }
    
    public var hours: TimeInterval {
        return TimeInterval(minutes*60)
    }
    
    public var days: TimeInterval {
        return TimeInterval(hours*24)
    }
}

private let TemporalCalendar = Calendar.autoupdatingCurrent


// equality

/**
 Same day as?
 */
public func ~=(lhs: Date, rhs: Date) -> Bool {
    return lhs.isTheSameDayAsDate(rhs)
}


// addition


public func +(lhs: Date, rhs: DateComponents) -> Date {
    return (TemporalCalendar as NSCalendar).date(byAdding: rhs, to: lhs, options:[])!
}

public func +(lhs: DateComponents, rhs: Date) -> Date {
    return (TemporalCalendar as NSCalendar).date(byAdding: lhs, to: rhs, options: [])!
}

public func +(lhs: DateComponents, rhs: DateComponents) -> DateComponents {
    
    var sum = DateComponents.zero()
    
    sum.era = lhs.era! + rhs.era!
    sum.nanosecond = lhs.nanosecond! + rhs.nanosecond!
    sum.year = lhs.year! + rhs.year!
    sum.month = lhs.month! + rhs.month!
    sum.day = lhs.day! + rhs.day!
    sum.hour = lhs.hour! + rhs.hour!
    sum.minute = lhs.minute! + rhs.minute!
    sum.second = lhs.second! + rhs.second!
    
    return sum
}

public prefix func -(components: DateComponents) -> DateComponents {
    var c = DateComponents.zero()
    
    if let comp = components.nanosecond     { c.nanosecond = -comp }
    if let comp = components.era            { c.era = -comp }
    if let comp = components.year           { c.year = -comp }
    if let comp = components.month          { c.month = -comp }
    if let comp = components.day            { c.day = -comp }
    if let comp = components.hour           { c.hour = -comp }
    if let comp = components.minute         { c.minute = -comp }
    if let comp = components.second         { c.second = -comp }
    if let comp = components.weekOfMonth    { c.weekOfMonth = -comp }
    
    return c
}

public func -(lhs: Date, rhs: DateComponents) -> Date {
    return lhs + -rhs
}

public extension Date {
    public init(year: Int, month: Int, day: Int) {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        let tx = TemporalCalendar.date(from: components)?.timeIntervalSinceReferenceDate
        self.init(timeIntervalSinceReferenceDate:tx!)
    }
    
    public var dateAtMidnight: Date {
        let components = (TemporalCalendar as NSCalendar).components([.day, .month, .year], from: self)
        return TemporalCalendar.date(from: components)!
    }
    
    public var dateOnSundayAtTheBeginningOfTheWeek: Date {
        let date = dateAtMidnight
        let component = (TemporalCalendar as NSCalendar).component(.weekday, from: self)
        return date - (component - 1).daysComponents
    }
    
    public func isTheSameDayAsDate(_ date: Date) -> Bool {
        let myComponents = (TemporalCalendar as NSCalendar).components([.day, .month, .year], from: self)
        let otherComponents = (TemporalCalendar as NSCalendar).components([.day, .month, .year], from: date)
        
        return myComponents.year == otherComponents.year && myComponents.month == otherComponents.month && myComponents.day == otherComponents.day
    }
    
    public var yyyyMMdd: String { return DateFormatter.yyyyMMdd.string(from: self) }
}

// returns an array of days (00:00:00) (removes time component) from the start date to finish date inclusive
public func ...(lhs: Date, rhs: Date) -> [Date] {
    let start =  lhs.dateAtMidnight
    let end = rhs.dateAtMidnight
    
    if end < start {
        return []
    }
    
    let dayCount = TemporalCalendar.dateComponents([.day], from: start, to: end).day ?? 0
    if dayCount <= 0 {
        return [start]
    }
    
    let range = 0...dayCount
    return range.map { i in
        start + i.days
    }
}

// returns an array of days (00:00:00) (removes time component) from the start date to finish date exclusive
public func ..<(lhs: Date, rhs: Date) -> [Date] {
    let start =  lhs.dateAtMidnight
    let end = rhs.dateAtMidnight

    if end < start {
        return []
    }

    let dayCount = (TemporalCalendar as NSCalendar).components(.day, from:start, to: end, options: []).day ?? 0
    if dayCount <= 0 {
        return [start]
    }

    let range = 0..<dayCount
    return range.map { i in
        start + i.days
    }
}

extension Calendar {
    public var numberOfDaysInWeek: Int {
        return maximumRange(of: .weekday)!.count
    }
}

open class Clock {
    static let sharedClock = Clock()

    var referenceDate = Date(timeIntervalSinceReferenceDate: 0)
    var referenceDateInterval: TimeInterval {
        get { return referenceDate.timeIntervalSinceReferenceDate }
        set { referenceDate = Date(timeIntervalSinceReferenceDate: newValue) }
    }

    open static func currentTime() -> Date {
        return Date(timeIntervalSinceNow: sharedClock.referenceDateInterval)
    }

    open static func timeTravel(to date: Date, block: ()->Void) {
        sharedClock.referenceDateInterval = date.timeIntervalSinceNow
        block()
        restoreTime()
    }

    static func restoreTime() {
        sharedClock.referenceDateInterval = 0
    }
}
