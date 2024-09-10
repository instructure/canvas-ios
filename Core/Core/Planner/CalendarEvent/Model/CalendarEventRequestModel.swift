//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

public struct CalendarEventRequestModel {
    let title: String
    let date: Date
    let isAllDay: Bool
    let startTime: Date
    let endTime: Date
    let contextCode: String
    let location: String?
    let address: String?
    let details: String?
}

extension CalendarEventRequestModel {
    var isValid: Bool {
        title.isNotEmpty
        && (isAllDay || startTime <= endTime)
    }

    var processedStartTime: Date {
        if isAllDay {
            date.startOfDay()
        } else {
            date.startOfDay()
                .addHours(startTime.hours)
                .addMinutes(startTime.minutes)
        }
    }

    var processedEndTime: Date {
        if isAllDay {
            date.startOfDay()
        } else {
            date.startOfDay()
                .addHours(endTime.hours)
                .addMinutes(endTime.minutes)
        }
    }

    var timeZone: String {
        Cal.currentCalendar.timeZone.identifier
    }
}

#if DEBUG
extension CalendarEventRequestModel {
    static func make(
        title: String = "",
        date: Date =  Clock.now.startOfDay(),
        isAllDay: Bool = false,
        startTime: Date = Clock.now.startOfDay(),
        endTime: Date = Clock.now.startOfDay(),
        contextCode: String = "",
        location: String? = nil,
        address: String? = nil,
        details: String? = nil
    ) -> CalendarEventRequestModel {
        .init(
            title: title,
            date: date,
            isAllDay: isAllDay,
            startTime: startTime,
            endTime: endTime,
            contextCode: contextCode,
            location: location,
            address: address,
            details: details
        )
    }
}
#endif
