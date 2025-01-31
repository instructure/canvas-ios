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
    /// The event repetition rule
    let rrule: String?
    /// Whether it is the first event of repeating events
    let series_head: Bool?
    /// The event repetition in human readable format
    let series_natural_language: String?
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
        created_at: Date = Clock.now.inCalendar.startOfHour(),
        updated_at: Date = Clock.now.inCalendar.startOfHour(),
        workflow_state: CalendarEventWorkflowState = .active,
        assignment: APIAssignment? = nil,
        description: String? = nil,
        location_name: String? = nil,
        location_address: String? = nil,
        hidden: Bool? = false,
        important_dates: Bool = false,
        rrule: String? = nil,
        series_head: Bool? = nil,
        series_natural_language: String? = "Weekly on Wed, 52 times"
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
            important_dates: important_dates,
            rrule: rrule,
            series_head: series_head,
            series_natural_language: series_natural_language
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
    public var useExtendedPercentEncoding: Bool { true }
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return formatter
    }()

    public init(
        contexts: [Context]? = nil,
        startDate: Date = Clock.now.inCalendar.addingYears(-2).startOfDay(),
        endDate: Date = Clock.now.inCalendar.addingYears(1).endOfDay(),
        calendar: Calendar = .current,
        timeZone: TimeZone = .current,
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
        Self.dateFormatter.calendar = calendar
        Self.dateFormatter.timeZone = timeZone
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
            .optionalValue("start_date", createDateString(from: startDate)),
            .optionalValue("end_date", createDateString(from: endDate)),
            .optionalBool("important_dates", importantDates)
        ]
        if let contexts = contexts {
            query.append(.array("context_codes", contexts.map { $0.canvasContextID }))
        }
        if let allEvents = allEvents {
            query.append(.bool("all_events", allEvents))
        }

        return query
    }

    private func createDateString(from date: Date?) -> String {
        if let date = date {
            return Self.dateFormatter.string(from: date)
        } else {
            return ""
        }
    }
}

// https://canvas.instructure.com/doc/api/calendar_events.html#method.calendar_events_api.show
public struct GetCalendarEventRequest: APIRequestable {
    public typealias Response = APICalendarEvent
    public enum Include: String, CaseIterable {
        case seriesNaturalLanguage = "series_natural_language"
    }
    public let eventID: String
    public var path: String { "calendar_events/\(eventID)" }
    public var query: [APIQueryItem] {
        [.include(Include.allCases.map(\.rawValue))]
    }
}
