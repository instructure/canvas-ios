//
//  CalendarEvent+Network.swift
//  Calendar
//
//  Created by Brandon Pluim on 3/7/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Marshal
import ReactiveCocoa
import TooLegit

extension CalendarEvent {

    static func getCalendarEvent(session: Session, calendarEventID: String) throws -> SignalProducer<JSONObject, NSError> {
        let request = try CalendarEventAPI.getCalendarEvent(session, calendarEventID: calendarEventID)
        return session.JSONSignalProducer(request)
    }

    static func getCalendarEvents(session: Session, type: CalendarEventAPI.RequestType, startDate: NSDate, endDate: NSDate, contextCodes: [String]? = nil) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try CalendarEventAPI.getCalendarEvents(session, type: type, startDate: startDate, endDate: endDate, contextCodes: contextCodes)
        return session.paginatedJSONSignalProducer(request)
    }

    static func getAllCalendarEvents(session: Session, startDate: NSDate, endDate: NSDate, contextCodes: [String]) throws -> SignalProducer<[JSONObject], NSError> {
        let getEvents = try getCalendarEvents(session, type: .Event, startDate: startDate, endDate: endDate, contextCodes: contextCodes)
        let getAssignments = try getCalendarEvents(session, type: .Assignment, startDate: startDate, endDate: endDate, contextCodes: contextCodes)
        let getPersonalAssignments = try getCalendarEvents(session, type: .Event, startDate: startDate, endDate: endDate)

        return getEvents.concat(getAssignments).concat(getPersonalAssignments)
    }
}