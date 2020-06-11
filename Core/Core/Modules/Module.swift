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

public enum ModuleState: String, Codable {
    case locked, unlocked, started, completed
}

public class Module: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var position: Int
    @NSManaged public var courseID: String
    @NSManaged public var publishedRaw: NSNumber?
    @NSManaged public var stateRaw: String?
    @NSManaged public var itemsRaw: NSOrderedSet?

    public var published: Bool? {
        get { return publishedRaw?.boolValue }
        set { publishedRaw = NSNumber(value: newValue) }
    }

    public var items: [ModuleItem] {
        get { return itemsRaw?.array as? [ModuleItem] ?? [] }
        set { itemsRaw = NSOrderedSet(array: newValue) }
    }

    public var state: ModuleState? {
        get { stateRaw.flatMap(ModuleState.init(rawValue:)) }
        set { stateRaw = newValue?.rawValue }
    }

    @discardableResult
    public static func save(_ items: [APIModule], forCourse courseID: String, in context: NSManagedObjectContext) -> [Module] {
        return items.map { save($0, forCourse: courseID, in: context) }
    }

    @discardableResult
    public static func save(_ item: APIModule, forCourse courseID: String, in context: NSManagedObjectContext) -> Module {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(Module.id), item.id.value)
        let module: Module = context.fetch(predicate).first ?? context.insert()
        module.id = item.id.value
        module.courseID = courseID
        module.name = item.name
        module.position = item.position
        module.published = item.published
        module.state = item.state
        module.items = item.items?.map { .save($0, forCourse: courseID, in: context) } ?? []
        return module
    }
}
