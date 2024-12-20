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

// https://canvas.instructure.com/doc/api/calendar_events.html#method.calendar_events_api.update
struct PutCalendarEventRequest: APIRequestable {
    typealias Response = [APICalendarEvent]

    var method: APIMethod { .put }
    var path: String { "calendar_events/\(id)" }

    let id: String
    let body: APICalendarEventRequestBody?

    // API can return either a single object or an array of objects, depending on whether the event repeats or not.
    public func decode(_ data: Data) throws -> [APICalendarEvent] {
        do {
            let event = try APIJSONDecoder().decode(APICalendarEvent.self, from: data)
            return [event]
        } catch {
            return try APIJSONDecoder().decode([APICalendarEvent].self, from: data)
        }
    }
}
