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
struct GetPlannerNotesRequest: APIRequestable {
    public typealias Response = [APIPlannerNote]

    public var path: String { "planner_notes" }

    let contexts: [Context]?
    let startDate: Date?
    let endDate: Date?
    let perPage: Int
    let calendar: Calendar

    public var useExtendedPercentEncoding: Bool { true }

    public init(
        contexts: [Context]? = nil,
        startDate: Date,
        endDate: Date,
        perPage: Int = 100,
        calendar: Calendar = Cal.currentCalendar
    ) {
        self.contexts = contexts
        self.startDate = startDate
        self.endDate = endDate
        self.perPage = perPage
        self.calendar = calendar
    }

    public var query: [APIQueryItem] {
        var query: [APIQueryItem] = [
            .perPage(perPage),
            .optionalValue("start_date", formatString(from: startDate)),
            .optionalValue("end_date", formatString(from: endDate))
        ]

        if let contexts = contexts {
            query.append(.array("context_codes", contexts.map { $0.canvasContextID }))
        }

        return query
    }

    private func formatString(from date: Date?) -> String {
        date?.queryParamFormatted(calendar: calendar) ?? ""
    }
}

// MARK: - Helpers

private extension Date {

    private static let requestQueryFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return formatter
    }()

    func queryParamFormatted(calendar: Calendar) -> String {
        let formatter = Self.requestQueryFormatter
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        return formatter.string(from: self)
    }
}
