//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

public struct APICalendarEvent: Codable, Equatable {
    let id: ID
    let html_url: URL
    let title: String
    let start_at: Date?
    let end_at: Date?
    let type: CalendarEventType
    let context_code: String
    let created_at: Date
    let updated_at: Date
    let workflow_state: CalendarEventWorkflowState
    let assignment: APIAssignment?
}

#if DEBUG
extension APICalendarEvent {
    public static func make(
        id: ID = "1",
        html_url: URL = URL(string: "https://narmstrong.instructure.com/calendar?event_id=10&include_contexts=course_1")!,
        title: String = "calendar event #1",
        start_at: Date? = Date(fromISOString: "2018-05-18T06:00:00Z"),
        end_at: Date? = Date(fromISOString: "2018-05-18T06:00:00Z"),
        type: CalendarEventType = .event,
        context_code: String = "course_1",
        created_at: Date = Clock.now,
        updated_at: Date = Clock.now,
        workflow_state: CalendarEventWorkflowState = .active,
        assignment: APIAssignment? = nil
    ) -> APICalendarEvent {
        return APICalendarEvent(
            id: id,
            html_url: html_url,
            title: title,
            start_at: start_at,
            end_at: end_at,
            type: type,
            context_code: context_code,
            created_at: created_at,
            updated_at: updated_at,
            workflow_state: workflow_state,
            assignment: assignment
        )
    }
}
#endif
