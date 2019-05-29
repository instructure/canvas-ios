//
// Copyright (C) 2019-present Instructure, Inc.
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
import CoreData

final public class CalendarEventItem: NSManagedObject, WriteableModel {
    public typealias JSON = APICalendarEvent

    @NSManaged public var id: String
    @NSManaged public var title: String
    @NSManaged public var startAt: Date?
    @NSManaged public var endAt: Date?
    @NSManaged public var type: String?
    @NSManaged public var htmlUrl: URL
    @NSManaged var contextRaw: String

    public var context: Context {
        get { return ContextModel(canvasContextID: contextRaw) ?? .currentUser }
        set { contextRaw = newValue.canvasContextID }
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
        return model
    }
}
