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

struct APICalendarEventRequestBody: Codable, Equatable {

    struct CalendarEvent: Codable, Equatable {
        let context_code: String
        let title: String
        let description: String?
        let start_at: Date
        let end_at: Date
        let location_name: String?
        let location_address: String?
        // TODO: let time_zone_edited: String?
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
        location_address: String? = nil
    ) -> PostCalendarEventRequest.Body {
        .init(
            calendar_event: .init(
                context_code: context_code,
                title: title,
                description: description,
                start_at: start_at,
                end_at: end_at,
                location_name: location_name,
                location_address: location_address
            )
        )
    }
}
#endif
