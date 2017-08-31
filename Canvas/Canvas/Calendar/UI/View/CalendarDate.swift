//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

import Foundation

public struct CalendarDate: Equatable {
    var year = 0
    var month = 0
    var day = 0
    
    public mutating func populate(_ date: Date, calendar: Calendar) {
        let components = (calendar as NSCalendar).components([.year, .month, .day], from: date)
        year = components.year!
        month = components.month!
        day = components.day!
    }
    
    public func date(_ calendar: Calendar) -> Date {
        var components = DateComponents()
        components.day = day
        components.month = month
        components.year = year
        return calendar.date(from: components)!
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
