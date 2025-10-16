//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import CoreData
import Foundation

public final class CDHCourseTools: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var courseContextsCodes: String
    @NSManaged public var name: String
    @NSManaged public var url: URL?
    @NSManaged public var iconURL: URL?

    @discardableResult
     static func save(
        apiEntity: CourseNavigationTool,
        courseContextsCodes: String,
        in context: NSManagedObjectContext
    ) -> CDHCourseTools {
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "%K == %@", #keyPath(CDHCourseTools.id), apiEntity.id.defaultToEmpty),
            NSPredicate(format: "%K == %@", #keyPath(CDHCourseTools.courseContextsCodes), courseContextsCodes)
        ])

        let entity: CDHCourseTools = context.fetch(predicate).first ?? context.insert()
        entity.id = apiEntity.id.defaultToEmpty
        entity.name = apiEntity.name.defaultToEmpty
        entity.courseContextsCodes = courseContextsCodes
        entity.url = apiEntity.url
        entity.iconURL = apiEntity.course_navigation?.icon_url
        return entity
    }
}
