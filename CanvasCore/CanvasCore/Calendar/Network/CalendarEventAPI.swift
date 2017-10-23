//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
            "start_date": CalendarEvent.dayDateFormatter.string(from: startDate),
            "end_date": CalendarEvent.dayDateFormatter.string(from: endDate),
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

