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
import CoreData

public enum CalendarEventType: String, Codable {
    case assignment, event
}

public enum CalendarEventWorkflowState: String, Codable {
    case active, deleted, locked, published, unpublished
}

final public class CalendarEvent: NSManagedObject, WriteableModel {
    public typealias JSON = APICalendarEvent

    @NSManaged public var id: String
    @NSManaged public var title: String
    @NSManaged public var startAt: Date?
    @NSManaged public var endAt: Date?
    @NSManaged public var isAllDay: Bool
    @NSManaged public var isHidden: Bool
    @NSManaged public var typeRaw: String
    @NSManaged public var htmlURL: URL?
    @NSManaged public var contextRaw: String
    @NSManaged public var effectiveContextRaw: String?
    @NSManaged public var contextName: String?
    @NSManaged public var hasStartAt: Bool
    @NSManaged public var details: String?
    @NSManaged public var locationName: String?
    @NSManaged public var locationAddress: String?
    @NSManaged public var repetitionRule: String?
    @NSManaged public var isSeriesHead: Bool
    /// The event repetition in human readable format
    @NSManaged public var seriesInNaturalLanguage: String?

    public var context: Context {
        get { return Context(canvasContextID: contextRaw) ?? .currentUser }
        set { contextRaw = newValue.canvasContextID }
    }

    public var effectiveContext: Context? {
        get { effectiveContextRaw.flatMap { Context(canvasContextID: $0) } }
        set { effectiveContextRaw = newValue?.canvasContextID }
    }

    public var type: CalendarEventType {
        get { return CalendarEventType(rawValue: typeRaw) ?? .event }
        set { typeRaw = newValue.rawValue }
    }

    public var isPartOfSeries: Bool {
        repetitionRule?.nilIfEmpty != nil && seriesInNaturalLanguage?.nilIfEmpty != nil
    }

    public var routingURL: URL {
        return URL(string: "calendar_events/\(id)")!
    }

    @discardableResult
    public static func save(_ item: APICalendarEvent, in context: NSManagedObjectContext) -> CalendarEvent {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(CalendarEvent.id), item.id.value)
        let model: CalendarEvent = context.fetch(predicate).first ?? context.insert()
        model.id = item.id.value
        model.title = item.title
        model.startAt = item.start_at
        model.endAt = item.end_at
        model.isAllDay = item.all_day
        model.isHidden = item.isHidden
        model.type = item.type
        model.htmlURL = item.html_url
        model.contextRaw = item.context_code
        model.effectiveContextRaw = item.effective_context_code
        model.contextName = item.context_name
        model.hasStartAt = item.start_at != nil
        model.details = item.description
        model.locationName = item.location_name
        model.locationAddress = item.location_address
        model.repetitionRule = item.rrule
        model.isSeriesHead = item.series_head ?? false
        model.seriesInNaturalLanguage = item.series_natural_language
        return model
    }
}

// MARK: - Frequency

extension CalendarEvent {
    var recurrenceRule: RecurrenceRule? {
        repetitionRule.flatMap { RecurrenceRule(rruleDescription: $0) }
    }
}
