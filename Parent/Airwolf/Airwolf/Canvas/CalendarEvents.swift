//
//  CalendarEvents.swift
//  Airwolf
//
//  Created by Ben Kraus on 5/19/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import TooLegit
import SoPersistent
import ReactiveCocoa
import Marshal
import CalendarKit

extension CalendarEvent {
    // MARK: - Collection
    public static func getCalendarEventsFromAirwolf(session: Session, studentID: String, startDate: NSDate, endDate: NSDate, contextCodes: [String]) throws -> SignalProducer<[JSONObject], NSError> {
        let nillableParams: [String: AnyObject?] = [
            "start_date": CalendarEvent.dayDateFormatter.stringFromDate(startDate),
            "end_date": CalendarEvent.dayDateFormatter.stringFromDate(endDate),
            "context_codes": contextCodes,
            "include": ["submission"]
        ]

        let parameters = Session.rejectNilParameters(nillableParams)
        
        let request = try session.GET("/canvas/\(session.user.id)/\(studentID)/calendar_events", parameters: parameters)
        return session.paginatedJSONSignalProducer(request)
    }

    public static func calendarEventsAirwolfCollectionRefresher(session: Session, studentID: String, startDate: NSDate, endDate: NSDate, contextCodes: [String]) throws -> Refresher {
        let predicate = CalendarEvent.predicate(startDate, endDate: endDate, contextCodes: contextCodes)
        let remote = try CalendarEvent.getCalendarEventsFromAirwolf(session, studentID: studentID, startDate: startDate, endDate: endDate, contextCodes: contextCodes)
        let context = try session.calendarEventsManagedObjectContext(studentID)
        let sync = CalendarEvent.syncSignalProducer(predicate, inContext: context, fetchRemote: remote)

        let key = cacheKey(context, [studentID, startDate.yyyyMMdd, endDate.yyyyMMdd] + contextCodes.sort())
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    // MARK: - Details
    public static func getCourseCalendarEventFromAirwolf(session: Session, studentID: String, calendarEventID: String) throws -> SignalProducer<JSONObject, NSError> {
        let request = try session.GET("/canvas/\(session.user.id)/\(studentID)/calendar_events/\(calendarEventID)")
        return session.JSONSignalProducer(request)
    }

    public static func refresher(session: Session, studentID: String, calendarEventID: String) throws -> Refresher {
        let predicate = CalendarEvent.predicate(calendarEventID)
        let remote = try CalendarEvent.getCourseCalendarEventFromAirwolf(session, studentID: studentID, calendarEventID: calendarEventID).map { [$0] }
        let context = try session.calendarEventsManagedObjectContext(studentID)
        let sync = CalendarEvent.syncSignalProducer(predicate, inContext: context, fetchRemote: remote)

        let key = cacheKey(context, [studentID, calendarEventID])
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    public static func observer(session: Session, studentID: String, calendarEventID: String) throws -> ManagedObjectObserver<CalendarEvent> {
        let pred = predicate(calendarEventID)
        let context = try session.calendarEventsManagedObjectContext(studentID)
        return try ManagedObjectObserver<CalendarEvent>(predicate: pred, inContext: context)
    }
}