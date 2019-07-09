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

    public let path = "calendar_events"
    public let context: Context
    public let startDate: Date
    public let endDate: Date
    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "YYYY-MM-dd"
        return df
    }()

    init(context: Context, startDate: Date = Clock.now.addYears(-2), endDate: Date = Clock.now.addYears(1)) {
        self.context = context
        self.startDate = startDate
        self.endDate = endDate
    }

    public var query: [APIQueryItem] {
        return [
            .array("context_codes", [context.canvasContextID]),
            .value("type", "event"),
            .value("start_date", GetCalendarEventsRequest.dateFormatter.string(from: startDate)),
            .value("end_date", GetCalendarEventsRequest.dateFormatter.string(from: endDate)),
            .value("per_page", "100"),
        ]
    }
}
