//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

public class Cal {
    private static let shared = Cal()
    private var mockCalendar: Calendar?

    public static func reset() {
        shared.mockCalendar = nil
    }

    public static func mockCalendar(_ c: Calendar, timeZone: TimeZone = TimeZone.autoupdatingCurrent) {
        var mockCal = c
        mockCal.timeZone = timeZone
        shared.mockCalendar = mockCal
    }

    public static var currentCalendar: Calendar {
        #if DEBUG
        if let mock = shared.mockCalendar {
            return mock
        }
        #endif
        return Calendar.current
    }
}

public class Clock {
    private static let shared = Clock()
    private var mockNow: Date?

    public static func reset() {
        shared.mockNow = nil
    }

    public static func mockNow(_ now: Date) {
        shared.mockNow = now
    }

    public static var now: Date {
        #if DEBUG
        if let mockNow = shared.mockNow {
            return mockNow
        }
        #endif
        return Date()
    }
}
