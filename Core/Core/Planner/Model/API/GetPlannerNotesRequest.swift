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

/// https://canvas.instructure.com/doc/api/planner.html#method.planner_notes.index
public struct GetPlannerNotesRequest: APIRequestable {
    public typealias Response = [APIPlannerNote]

    public var path: String { "planner_notes" }

    public let contexts: [Context]?
    public let startDate: Date?
    public let endDate: Date?
    public let perPage: Int

    public var useExtendedPercentEncoding: Bool { true }
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return formatter
    }()

    public init(
        contexts: [Context]? = nil,
        startDate: Date = Clock.now.addYears(-2),
        endDate: Date = Clock.now.addYears(1),
        perPage: Int = 100,
        calendar: Calendar = .current,
        timeZone: TimeZone = .current
    ) {
        self.contexts = contexts
        self.startDate = startDate
        self.endDate = endDate
        Self.dateFormatter.calendar = calendar
        Self.dateFormatter.timeZone = timeZone
        self.perPage = perPage
    }

    public var query: [APIQueryItem] {
        var query: [APIQueryItem] = [
            .perPage(perPage),
            .optionalValue("start_date", createDateString(from: startDate)),
            .optionalValue("end_date", createDateString(from: endDate))
        ]

        if let contexts = contexts {
            query.append(.array("context_codes", contexts.map { $0.canvasContextID }))
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
