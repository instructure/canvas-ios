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

public enum APICalendarEventSeriesModificationType: String, Codable {
    case one
    case all
    case following
}

// https://canvas.instructure.com/doc/api/calendar_events.html#method.calendar_events_api.create
// https://canvas.instructure.com/doc/api/calendar_events.html#method.calendar_events_api.update
struct APICalendarEventRequestBody: Codable, Equatable {

    struct CalendarEvent: Codable, Equatable {
        let context_code: String
        let title: String
        let description: String?
        let start_at: Date
        let end_at: Date
        let location_name: String?
        let location_address: String?
        let time_zone_edited: String? // Needed for proper all_day calculation, otherwise account timezone would be used instead of device timezone
        // let all_day: Bool? // We are not sending it, because we allow API to calculate it based start/end times (web does the same)
        let rrule: RecurrenceRule?

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(context_code, forKey: .context_code)
            try container.encode(title, forKey: .title)
            try container.encode(description, forKey: .description)
            try container.encode(start_at, forKey: .start_at)
            try container.encode(end_at, forKey: .end_at)
            try container.encode(location_name, forKey: .location_name)
            try container.encode(location_address, forKey: .location_address)
            try container.encode(time_zone_edited, forKey: .time_zone_edited)
            try container.encode(rrule, forKey: .rrule)
        }
    }

    let calendar_event: CalendarEvent
}

#if DEBUG
extension APICalendarEventRequestBody {
    static func make(
        context_code: String = "",
        title: String = "",
        description: String? = nil,
        start_at: Date = Clock.now.startOfDay(),
        end_at: Date = Clock.now.startOfDay(),
        location_name: String? = nil,
        location_address: String? = nil,
        time_zone_edited: String? = nil,
        rrule: RecurrenceRule? = nil
    ) -> PostCalendarEventRequest.Body {
        .init(
            calendar_event: .init(
                context_code: context_code,
                title: title,
                description: description,
                start_at: start_at,
                end_at: end_at,
                location_name: location_name,
                location_address: location_address,
                time_zone_edited: time_zone_edited,
                rrule: rrule
            )
        )
    }
}
#endif
