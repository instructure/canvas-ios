//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

open class CalendarEventAPI {

    public enum RequestType: String {
        case event = "event"
        case assignment = "assignment"
    }

    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "YYYY-MM-dd"
        return df
    }()

    open class func getCalendarEvents(_ session: Session, type: RequestType, startDate: Date, endDate: Date, contextCodes: [String]?, userID: String?) throws -> URLRequest {
        let path = userID.flatMap { "/api/v1/users/\($0)/calendar_events" } ?? "/api/v1/calendar_events"
        let nillableParams: [String: Any?] = [
            "type": type.rawValue,
            "start_date": dateFormatter.string(from: startDate),
            "end_date": dateFormatter.string(from: endDate),
            "context_codes": contextCodes,
            "include": ["submission"]
        ]

        let parameters = Session.rejectNilParameters(nillableParams)

        return try session.GET(path, parameters: parameters)
    }

    open class func getCalendarEvent(_ session: Session, calendarEventID: String) throws -> URLRequest {
        return try session.GET("/api/v1/calendar_events/\(calendarEventID)", paginated: false)
    }
    
}

