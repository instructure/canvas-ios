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
    
    

import Foundation


import ReactiveSwift
import Marshal
import CanvasCore

extension CalendarEvent {
    
    // MARK: - Collection
    public static func getCalendarEventsFromAirwolf(_ session: Session, studentID: String, startDate: Date, endDate: Date, contextCodes: [String]) throws -> SignalProducer<[JSONObject], NSError> {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        dateFormatter.locale = NSLocale(localeIdentifier: "en") as Locale!
        
        let nillableParams: [String: Any?] = [
            "start_date": dateFormatter.string(from: startDate),
            "end_date": dateFormatter.string(from: endDate),
            "context_codes": contextCodes,
            "include": ["submission"]
        ]

        let parameters = Session.rejectNilParameters(nillableParams)
        
        let request = try session.GET("/canvas/\(session.user.id)/\(studentID)/calendar_events", parameters: parameters)
        return session.paginatedJSONSignalProducer(request)
    }

    public static func calendarEventsAirwolfCollectionRefresher(_ session: Session, studentID: String, startDate: Date, endDate: Date, contextCodes: [String]) throws -> Refresher {
        let predicate = CalendarEvent.predicate(startDate, endDate: endDate, contextCodes: contextCodes)
        let remote = try CalendarEvent.getCalendarEventsFromAirwolf(session, studentID: studentID, startDate: startDate, endDate: endDate, contextCodes: contextCodes)
        let context = try session.calendarEventsManagedObjectContext(studentID)
        let sync = CalendarEvent.syncSignalProducer(predicate, inContext: context, fetchRemote: remote)

        let key = cacheKey(context, [studentID, startDate.yyyyMMdd, endDate.yyyyMMdd] + contextCodes.sorted())
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    // MARK: - Details
    public static func getCourseCalendarEventFromAirwolf(_ session: Session, studentID: String, calendarEventID: String) throws -> SignalProducer<JSONObject, NSError> {
        let request = try session.GET("/canvas/\(session.user.id)/\(studentID)/calendar_events/\(calendarEventID)")
        return session.JSONSignalProducer(request)
    }

    public static func refresher(_ session: Session, studentID: String, calendarEventID: String) throws -> Refresher {
        let predicate = CalendarEvent.predicate(calendarEventID)
        let remote = try CalendarEvent.getCourseCalendarEventFromAirwolf(session, studentID: studentID, calendarEventID: calendarEventID).map { [$0] }
        let context = try session.calendarEventsManagedObjectContext(studentID)
        let sync = CalendarEvent.syncSignalProducer(predicate, inContext: context, fetchRemote: remote)

        let key = cacheKey(context, [studentID, calendarEventID])
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    public static func observer(_ session: Session, studentID: String, calendarEventID: String) throws -> ManagedObjectObserver<CalendarEvent> {
        let pred = predicate(calendarEventID)
        let context = try session.calendarEventsManagedObjectContext(studentID)
        return try ManagedObjectObserver<CalendarEvent>(predicate: pred, inContext: context)
    }
}
