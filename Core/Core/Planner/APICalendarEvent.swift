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
    let description: String?
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
        assignment: APIAssignment? = nil,
        description: String? = nil
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
            assignment: assignment,
            description: description
        )
    }
}
#endif

// https://canvas.instructure.com/doc/api/all_resources.html#method.calendar_events_api.index
public struct GetCalendarEventsRequest: APIRequestable {
    public typealias Response = [APICalendarEvent]
    public enum Include: String {
        case submission
    }

    public var path: String {
        if let userID = userID {
            let context = Context(.user, id: userID)
            return "\(context.pathComponent)/calendar_events"
        }
        return "calendar_events"
    }
    public let contexts: [Context]?
    public let startDate: Date?
    public let endDate: Date?
    public let type: CalendarEventType
    public let perPage: Int
    public let include: [Include]
    public let allEvents: Bool?
    public let userID: String?
    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()

    public init(
        contexts: [Context]? = nil,
        startDate: Date = Clock.now.addYears(-2),
        endDate: Date = Clock.now.addYears(1),
        type: CalendarEventType = .event,
        perPage: Int = 100,
        include: [Include] = [],
        allEvents: Bool? = nil,
        userID: String? = nil
    ) {
        self.contexts = contexts
        self.startDate = startDate
        self.endDate = endDate
        self.type = type
        self.perPage = perPage
        self.include = include
        self.allEvents = allEvents
        self.userID = userID
    }

    public var query: [APIQueryItem] {
        var query: [APIQueryItem] = [
            .value("type", type.rawValue),
            .perPage(perPage),
            .include(include.map { $0.rawValue }),
            .optionalValue("start_date", startDate.map(GetCalendarEventsRequest.dateFormatter.string)),
            .optionalValue("end_date", endDate.map(GetCalendarEventsRequest.dateFormatter.string)),
        ]
        if let contexts = contexts {
            query.append(.array("context_codes", contexts.map { $0.canvasContextID }))
        }
        if let allEvents = allEvents {
            query.append(.bool("all_events", allEvents))
        }
        return query
    }
}

public struct GetCalendarEventRequest: APIRequestable {
    public typealias Response = APICalendarEvent

    public let id: String

    public init(id: String) {
        self.id = id
    }

    public var path: String {
        return "calendar_events/\(id)"
    }
}
