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
    case active, deleted, locked, published
}

final public class CalendarEventItem: NSManagedObject, WriteableModel {
    public typealias JSON = APICalendarEvent

    @NSManaged public var id: String
    @NSManaged public var title: String
    @NSManaged public var startAt: Date?
    @NSManaged public var endAt: Date?
    @NSManaged public var typeRaw: String
    @NSManaged public var htmlUrl: URL?
    @NSManaged public var contextRaw: String
    @NSManaged public var hasStartAt: Bool

    public var context: Context {
        get { return Context(canvasContextID: contextRaw) ?? .currentUser }
        set { contextRaw = newValue.canvasContextID }
    }

    public var type: CalendarEventType {
        get { return CalendarEventType(rawValue: typeRaw) ?? .event }
        set { typeRaw = newValue.rawValue }
    }

    public var routingURL: URL {
        return URL(string: "calendar_events/\(id)")!
    }

    @discardableResult
    public static func save(_ item: APICalendarEvent, in context: NSManagedObjectContext) -> CalendarEventItem {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(CalendarEventItem.id), item.id.value)
        let model: CalendarEventItem = context.fetch(predicate).first ?? context.insert()
        model.id = item.id.value
        model.title = item.title
        model.startAt = item.start_at
        model.endAt = item.end_at
        model.type = item.type
        model.htmlUrl = item.html_url
        model.contextRaw = item.context_code
        model.hasStartAt = item.start_at != nil
        return model
    }
}
