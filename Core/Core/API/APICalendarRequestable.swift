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

public struct GetCalendarEventsRequest: APIRequestable {
    public typealias Response = [APICalendarEvent]
    public enum Include: String {
        case submission
    }

    public let path = "calendar_events"
    public let contexts: [Context]?
    public let startDate: Date
    public let endDate: Date
    public let type: CalendarEventType
    public let perPage: Int
    public let include: [Include]
    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "YYYY-MM-dd"
        return df
    }()

    public init(
        contexts: [Context]? = nil,
        startDate: Date = Clock.now.addYears(-2),
        endDate: Date = Clock.now.addYears(1),
        type: CalendarEventType = .event,
        perPage: Int = 100,
        include: [Include] = []
    ) {
        self.contexts = contexts
        self.startDate = startDate
        self.endDate = endDate
        self.type = type
        self.perPage = perPage
        self.include = include
    }

    public var query: [APIQueryItem] {
        var query: [APIQueryItem] = [
            .value("type", type.rawValue),
            .value("start_date", GetCalendarEventsRequest.dateFormatter.string(from: startDate)),
            .value("end_date", GetCalendarEventsRequest.dateFormatter.string(from: endDate)),
            .value("per_page", String(perPage)),
            .include(include.map { $0.rawValue }),
        ]
        if let contexts = contexts {
            query.append(.array("context_codes", contexts.map { $0.canvasContextID }))
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
