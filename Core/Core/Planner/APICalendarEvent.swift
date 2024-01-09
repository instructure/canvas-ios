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

// https://canvas.instructure.com/doc/api/calendar_events.html#CalendarEvent
public struct APICalendarEvent: Codable, Equatable {
    let id: ID
    let html_url: URL
    let title: String
    let start_at: Date?
    let end_at: Date?
    let all_day: Bool
    let type: CalendarEventType
    let context_code: String
    let effective_context_code: String?
    let context_name: String?
    let created_at: Date
    let updated_at: Date
    let workflow_state: CalendarEventWorkflowState
    let assignment: APIAssignment?
    let description: String?
    let location_name: String?
    let location_address: String?
    let hidden: Bool?
    let important_dates: Bool
}

#if DEBUG
extension APICalendarEvent {
    public static func make(
        id: ID = "1",
        html_url: URL = URL(string: "https://narmstrong.instructure.com/calendar?event_id=10&include_contexts=course_1")!,
        title: String = "calendar event #1",
        start_at: Date? = Date(fromISOString: "2018-05-18T06:00:00Z"),
        end_at: Date? = Date(fromISOString: "2018-05-18T06:00:00Z"),
        all_day: Bool = false,
        type: CalendarEventType = .event,
        context_code: String = "course_1",
        effective_context_code: String? = nil,
        context_name: String? = "Course One",
        created_at: Date = Clock.now,
        updated_at: Date = Clock.now,
        workflow_state: CalendarEventWorkflowState = .active,
        assignment: APIAssignment? = nil,
        description: String? = nil,
        location_name: String? = nil,
        location_address: String? = nil,
        hidden: Bool? = false,
        important_dates: Bool = false
    ) -> APICalendarEvent {
        return APICalendarEvent(
            id: id,
            html_url: html_url,
            title: title,
            start_at: start_at,
            end_at: end_at,
            all_day: all_day,
            type: type,
            context_code: context_code,
            effective_context_code: effective_context_code,
            context_name: context_name,
            created_at: created_at,
            updated_at: updated_at,
            workflow_state: workflow_state,
            assignment: assignment,
            description: description,
            location_name: location_name,
            location_address: location_address,
            hidden: hidden,
            important_dates: important_dates
        )
    }
}
#endif

// https://canvas.instructure.com/doc/api/calendar_events.html#method.calendar_events_api.index
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
    public let importantDates: Bool?
    public static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
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
        userID: String? = nil,
        importantDates: Bool? = nil
    ) {
        self.contexts = contexts
        self.startDate = startDate
        self.endDate = endDate
        self.type = type
        self.perPage = perPage
        self.include = include
        self.allEvents = allEvents
        self.userID = userID
        self.importantDates = importantDates
    }

    public var query: [APIQueryItem] {
        var query: [APIQueryItem] = [
            .value("type", type.rawValue),
            .perPage(perPage),
            .include(include.map { $0.rawValue }),
            .optionalValue("start_date", startDate.map(GetCalendarEventsRequest.dateFormatter.string)),
            .optionalValue("end_date", endDate.map(GetCalendarEventsRequest.dateFormatter.string)),
            .optionalBool("important_dates", importantDates),
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

// https://canvas.instructure.com/doc/api/calendar_events.html#method.calendar_events_api.show
public struct GetCalendarEventRequest: APIRequestable {
    public typealias Response = APICalendarEvent
    public let eventID: String
    public var path: String { "calendar_events/\(eventID)" }
}
