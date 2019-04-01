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

private let encoder = JSONEncoder()
private let decoder = JSONDecoder()

public class ModuleItem: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var courseID: String
    @NSManaged public var moduleID: String
    @NSManaged public var position: Int
    @NSManaged public var title: String
    @NSManaged public var indent: Int
    @NSManaged public var htmlURL: URL?
    @NSManaged public var url: URL?
    @NSManaged public var published: Bool
    @NSManaged public var typeRaw: Data?
    @NSManaged public var module: Module?
    @NSManaged public var dueAt: Date?

    public var type: ModuleItemType? {
        get {
            if let data = typeRaw {
                return try? decoder.decode(ModuleItemType.self, from: data)
            }
            return nil
        }
        set { typeRaw = try? encoder.encode(newValue) }
    }

    @discardableResult
    public static func save(_ item: APIModuleItem, forCourse courseID: String, in context: PersistenceClient) -> ModuleItem {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(ModuleItem.id), item.id.value)
        let model: ModuleItem = context.fetch(predicate).first ?? context.insert()
        model.id = item.id.value
        model.moduleID = item.module_id.value
        model.position = item.position
        model.title = item.title
        model.indent = item.indent
        model.htmlURL = item.html_url
        model.url = item.url
        model.published = item.published ?? false
        model.type = item.content
        model.courseID = courseID
        model.dueAt = item.content_details.due_at
        return model
    }
}
