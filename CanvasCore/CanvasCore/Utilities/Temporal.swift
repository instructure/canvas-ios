//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
    var formattedDueDate: String {
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
    @objc static var LongStyleDateFormatter: DateFormatter { return _LongStyleDateFormatter }
    @objc static var MediumStyleDateTimeFormatter: DateFormatter { return _MediumStyleDateTimeFormatter }
    @objc static var yyyyMMdd: DateFormatter { return _yyyyMMdd }
    @objc static var relativeShortDateAndTime: DateFormatter { return _relativeShortDateAndTime }
    @objc static var relativeShortDate: DateFormatter { return _relativeShortDate }
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
    var nanosecondsComponents: DateComponents {
        var c = DateComponents.zero()
        c.nanosecond = self
        return c
    }
    
    var secondsComponents: DateComponents {
        var c = DateComponents.zero()
        c.second = self
        return c
    }
    
    var minutesComponents: DateComponents {
        var c = DateComponents.zero()
        c.minute = self
        return c
    }
    
    var hoursComponents: DateComponents {
        var c = DateComponents.zero()
        c.hour = self
        return c
    }
    
    var daysComponents: DateComponents {
        var c = DateComponents.zero()
        c.day = self
        return c
    }
    
    var weeksComponents: DateComponents {
        var c = DateComponents.zero()
        c.weekOfMonth = self
        return c
    }
    
    var monthsComponents: DateComponents {
        var c = DateComponents.zero()
        c.month = self
        return c
    }
    
    var yearsComponents: DateComponents {
        var c = DateComponents.zero()
        c.year = self
        return c
    }
}

public extension Int {
    var minutes: TimeInterval {
        return TimeInterval(self*60)
    }
    
    var hours: TimeInterval {
        return TimeInterval(minutes*60)
    }
    
    var days: TimeInterval {
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
    init(year: Int, month: Int, day: Int) {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        let tx = TemporalCalendar.date(from: components)?.timeIntervalSinceReferenceDate
        self.init(timeIntervalSinceReferenceDate:tx!)
    }
    
    var dateAtMidnight: Date {
        let components = (TemporalCalendar as NSCalendar).components([.day, .month, .year], from: self)
        return TemporalCalendar.date(from: components)!
    }
    
    var dateOnSundayAtTheBeginningOfTheWeek: Date {
        let date = dateAtMidnight
        let component = (TemporalCalendar as NSCalendar).component(.weekday, from: self)
        return date - (component - 1).daysComponents
    }
    
    func isTheSameDayAsDate(_ date: Date) -> Bool {
        let myComponents = (TemporalCalendar as NSCalendar).components([.day, .month, .year], from: self)
        let otherComponents = (TemporalCalendar as NSCalendar).components([.day, .month, .year], from: date)
        
        return myComponents.year == otherComponents.year && myComponents.month == otherComponents.month && myComponents.day == otherComponents.day
    }
    
    var yyyyMMdd: String { return DateFormatter.yyyyMMdd.string(from: self) }
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

    public static func currentTime() -> Date {
        return Date(timeIntervalSinceNow: sharedClock.referenceDateInterval)
    }

    public static func timeTravel(to date: Date, block: ()->Void) {
        sharedClock.referenceDateInterval = date.timeIntervalSinceNow
        block()
        restoreTime()
    }

    static func restoreTime() {
        sharedClock.referenceDateInterval = 0
    }
}
