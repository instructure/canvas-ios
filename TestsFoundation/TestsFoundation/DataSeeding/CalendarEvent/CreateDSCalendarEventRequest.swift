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
        let start_at: String?
        let end_at: String?

        public init(courseId: String, title: String, description: String, start_at: String? = nil, end_at: String? = nil) {
            self.context_code = "course_\(courseId)"
            self.title = title
            self.description = description
            self.start_at = start_at
            self.end_at = end_at
        }
    }

    public struct Body: Encodable {
        let calendar_event: RequestedDSCalendarEvent

        public init(calendar_event: RequestedDSCalendarEvent) {
            self.calendar_event = calendar_event
        }
    }
}
