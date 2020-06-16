//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

public final class Group: NSManagedObject, WriteableModel {
    public typealias JSON = APIGroup

    @NSManaged public var avatarURL: URL?
    @NSManaged public var concluded: Bool
    @NSManaged public var courseID: String?
    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var showOnDashboard: Bool

    public var canvasContextID: String {
        Context(.group, id: id).canvasContextID
    }

    @discardableResult
    public static func save(_ item: APIGroup, in context: NSManagedObjectContext) -> Group {
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
        let request = NSFetchRequest<ContextColor>(entityName: String(describing: ContextColor.self))
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(ContextColor.canvasContextID), canvasContextID)
        if let color = try? managedObjectContext?.fetch(request).first {
            return color.color
        }
        if let courseID = courseID {
            let course = Context(.course, id: courseID)
            request.predicate = NSPredicate(format: "%K == %@", #keyPath(ContextColor.canvasContextID), course.canvasContextID)
            if let color = try? managedObjectContext?.fetch(request).first {
                return color.color
            }
        }
        return .named(.ash)
    }
}
