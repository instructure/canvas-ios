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