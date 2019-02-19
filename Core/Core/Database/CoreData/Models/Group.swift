//
// Copyright (C) 2018-present Instructure, Inc.
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

public class Group: NSManagedObject, Context {
    public let contextType = ContextType.group

    @NSManaged public var avatarURL: URL?
    @NSManaged public var concluded: Bool
    @NSManaged public var courseID: String?
    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var showOnDashboard: Bool

    @discardableResult
    public static func save(_ items: [APIGroup], in context: PersistenceClient) -> [Group] {
        return items.map { save($0, in: context) }
    }

    @discardableResult
    public static func save(_ item: APIGroup, in context: PersistenceClient) -> Group {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(Group.id), item.id.value)
        let model: Group = context.fetch(predicate).first ?? context.insert()
        model.avatarURL = item.avatar_url
        model.courseID = item.course_id?.value
        model.id = item.id.value
        model.name = item.name
        model.concluded = item.concluded
        model.showOnDashboard = !item.concluded
        return model
    }
}

extension Group {
    public var color: UIColor {
        let request = NSFetchRequest<Color>(entityName: String(describing: Color.self))
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(Color.canvasContextID), canvasContextID)
        if let first = try? managedObjectContext?.fetch(request).first, let color = first {
            return color.color
        }
        if let courseID = courseID {
            let course = ContextModel(.course, id: courseID)
            request.predicate = NSPredicate(format: "%K == %@", #keyPath(Color.canvasContextID), course.canvasContextID)
            if let first = try? managedObjectContext?.fetch(request).first, let color = first {
                return color.color
            }
        }
        return .named(.ash)
    }
}

extension Group: Scoped {
    public enum ScopeKeys {
        case details(String)
        case dashboard
    }

    public static func scope(forName name: ScopeKeys) -> Scope {
        switch name {
        case let .details(id):
            return .where(#keyPath(Group.id), equals: id)
        case .dashboard:
            return .where(#keyPath(Group.concluded), equals: false, orderBy: #keyPath(Group.name))
        }
    }
}
