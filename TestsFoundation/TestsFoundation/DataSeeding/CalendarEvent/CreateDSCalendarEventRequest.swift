//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import Core

// https://canvas.instructure.com/doc/api/conversations.html#method.conversations.create
public struct CreateDSCalendarEventRequest: APIRequestable {
    public typealias Response = DSCalendarEvent

    public let method = APIMethod.post
    public let path: String
    public let body: Body?

    public init(body: Body) {
        self.path = "calendar_events"
        self.body = body
    }
}

extension CreateDSCalendarEventRequest {
    public struct RequestedDSCalendarEvent: Encodable {
        let context_code: String
        let title: String
        let description: String
        let start_at: Date?
        let end_at: Date?
        let location_name: String?
        let location_address: String?
        let time_zone_edited: String
        let all_day: Bool?
        let rrule: String?
        let blackout_date: Bool?
        let duplicate: DSDuplicate?

        public init(courseId: String,
                    title: String,
                    description: String,
                    start_at: Date? = nil,
                    end_at: Date? = nil,
                    location_name: String? = nil,
                    location_address: String? = nil,
                    time_zone_edited: String = "Europe/Budapest",
                    all_day: Bool? = nil,
                    rrule: String? = nil,
                    blackout_date: Bool? = nil,
                    duplicate: DSDuplicate? = nil) {
            self.context_code = "course_\(courseId)"
            self.title = title
            self.description = description
            self.start_at = start_at
            self.end_at = end_at
            self.location_name = location_name
            self.location_address = location_address
            self.time_zone_edited = time_zone_edited
            self.all_day = all_day
            self.rrule = rrule
            self.blackout_date = blackout_date
            self.duplicate = duplicate
        }
    }

    public struct DSDuplicate: Encodable {
        let count: Int
        let frequency: String
        let append_iterator: Bool

        public init(count: Int, frequency: DSFrequency, append_iterator: Bool = true) {
            self.count = count
            self.frequency = frequency.rawValue
            self.append_iterator = append_iterator
        }
    }

    public struct Body: Encodable {
        let calendar_event: RequestedDSCalendarEvent

        public init(calendar_event: RequestedDSCalendarEvent) {
            self.calendar_event = calendar_event
        }
    }
}

public enum DSFrequency: String {
    case daily
    case weekly
    case monthly
}
