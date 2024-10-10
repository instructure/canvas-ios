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

public class GetCalendarEvents: CollectionUseCase {
    public typealias Model = CalendarEvent
    public typealias Response = [APICalendarEvent]
    public var cacheKey: String? {
        let contextPathString = contexts.map({ $0.pathComponent }).joined(separator: "|")
        return "(\(contextPathString))/calendar-events/\(type.rawValue)"
    }
    public let contexts: [Context]
    public let type: CalendarEventType
    private let importantDates: Bool

    public init(context: Context, type: CalendarEventType = .event, importantDates: Bool = false) {
        self.contexts = [context]
        self.type = type
        self.importantDates = importantDates
    }

    public init(contexts: [Context], type: CalendarEventType = .event, importantDates: Bool = false) {
        self.contexts = contexts
        self.type = type
        self.importantDates = importantDates
    }

    public var request: GetCalendarEventsRequest {
        return GetCalendarEventsRequest(contexts: contexts, type: type, allEvents: true, importantDates: importantDates)
    }

    public var scope: Scope {
        let context = NSPredicate(format: "%K IN %@", #keyPath(CalendarEvent.contextRaw), self.contexts.map {$0.canvasContextID})
        let type = NSPredicate(format: "%K == %@", #keyPath(CalendarEvent.typeRaw), self.type.rawValue)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [context, type])
        let title = NSSortDescriptor(key: #keyPath(CalendarEvent.title), ascending: true, naturally: true)

        return Scope(predicate: predicate, order: [title])
    }
}

public class GetCalendarEvent: APIUseCase {
    public typealias Model = CalendarEvent

    public let eventID: String

    public init(eventID: String) {
        self.eventID = eventID
    }

    public var cacheKey: String? { "calendar_events/\(eventID)" }

    public var request: GetCalendarEventRequest { GetCalendarEventRequest(eventID: eventID) }

    public var scope: Scope { .where(#keyPath(CalendarEvent.id), equals: eventID) }
}
