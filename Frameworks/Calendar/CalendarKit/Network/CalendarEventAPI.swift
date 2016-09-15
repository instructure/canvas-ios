//
//  CalendarEventAPI.swift
//  Calendar
//
//  Created by Brandon Pluim on 3/7/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import TooLegit
import SoLazy

public class CalendarEventAPI {

    public enum RequestType: String {
        case Event = "event"
        case Assignment = "assignment"
    }

    public class func getCalendarEvents(session: Session, type: RequestType, startDate: NSDate, endDate: NSDate, contextCodes: [String]?) throws -> NSURLRequest {
        let path = "/api/v1/calendar_events"
        let nillableParams: [String: AnyObject?] = [
            "type": type.rawValue,
            "start_date": CalendarEvent.dayDateFormatter.stringFromDate(startDate),
            "end_date": CalendarEvent.dayDateFormatter.stringFromDate(endDate),
            "context_codes": contextCodes,
            "include": ["submission"]
        ]

        let parameters = Session.rejectNilParameters(nillableParams)

        return try session.GET(path, parameters: parameters)
    }

    public class func getCalendarEvent(session: Session, calendarEventID: String) throws -> NSURLRequest {
        return try session.GET("/api/v1/calendar_events/\(calendarEventID)")
    }
    
}

