//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    




open class CalendarEventAPI {

    public enum RequestType: String {
        case event = "event"
        case assignment = "assignment"
    }

    open class func getCalendarEvents(_ session: Session, type: RequestType, startDate: Date, endDate: Date, contextCodes: [String]?) throws -> URLRequest {
        let path = "/api/v1/calendar_events"
        let nillableParams: [String: Any?] = [
            "type": type.rawValue,
            "start_date": ISO8601DateFormatter.string(from: startDate, timeZone: TimeZone(abbreviation: "UTC")!, formatOptions: .withInternetDateTime),
            "end_date": ISO8601DateFormatter.string(from: endDate, timeZone: TimeZone(abbreviation: "UTC")!, formatOptions: .withInternetDateTime),
            "context_codes": contextCodes,
            "include": ["submission"]
        ]

        let parameters = Session.rejectNilParameters(nillableParams)

        return try session.GET(path, parameters: parameters)
    }

    open class func getCalendarEvent(_ session: Session, calendarEventID: String) throws -> URLRequest {
        return try session.GET("/api/v1/calendar_events/\(calendarEventID)")
    }
    
}

