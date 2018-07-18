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
    
    

import Marshal
import ReactiveSwift


extension CalendarEvent {

    static func getCalendarEvent(_ session: Session, calendarEventID: String) throws -> SignalProducer<JSONObject, NSError> {
        let request = try CalendarEventAPI.getCalendarEvent(session, calendarEventID: calendarEventID)
        return session.JSONSignalProducer(request)
    }

    public static func getCalendarEvents(_ session: Session, type: CalendarEventAPI.RequestType, startDate: Date, endDate: Date, contextCodes: [String]? = nil) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try CalendarEventAPI.getCalendarEvents(session, type: type, startDate: startDate, endDate: endDate, contextCodes: contextCodes)
        return session.paginatedJSONSignalProducer(request)
    }

    static func getAllCalendarEvents(_ session: Session, startDate: Date, endDate: Date, contextCodes: [String]) throws -> SignalProducer<[JSONObject], NSError> {
        let getEvents = try getCalendarEvents(session, type: .event, startDate: startDate, endDate: endDate, contextCodes: contextCodes)
        let getAssignments = try getCalendarEvents(session, type: .assignment, startDate: startDate, endDate: endDate, contextCodes: contextCodes)
        let getPersonalAssignments = try getCalendarEvents(session, type: .event, startDate: startDate, endDate: endDate)

        return getEvents.concat(getAssignments).concat(getPersonalAssignments)
    }
}
