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
    
    

import Marshal
import ReactiveSwift


extension CalendarEvent {

    static func getCalendarEvent(_ session: Session, calendarEventID: String) throws -> SignalProducer<JSONObject, NSError> {
        let request = try CalendarEventAPI.getCalendarEvent(session, calendarEventID: calendarEventID)
        return session.JSONSignalProducer(request)
    }

    static func getCalendarEvents(_ session: Session, type: CalendarEventAPI.RequestType, startDate: Date, endDate: Date, contextCodes: [String]? = nil) throws -> SignalProducer<[JSONObject], NSError> {
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
