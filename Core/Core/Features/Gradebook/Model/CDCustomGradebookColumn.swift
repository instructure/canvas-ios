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

public class CDCustomGradebookColumn: NSManagedObject {

    @NSManaged public private(set) var courseId: String

    @NSManaged public var id: String
    @NSManaged public var title: String
    @NSManaged public var position: Int
    @NSManaged public var isHidden: Bool
    @NSManaged public var isReadOnly: Bool
    @NSManaged public var isTeacherNotes: Bool

    @discardableResult
    public static func save(
        _ item: APICustomGradebookColumn,
        courseId: String,
        in moContext: NSManagedObjectContext
    ) -> CDCustomGradebookColumn {

        let predicate = NSPredicate(key: (\CDCustomGradebookColumn.courseId).string, equals: courseId)
            .and(NSPredicate(key: (\CDCustomGradebookColumn.id).string, equals: item.id))

        let model: CDCustomGradebookColumn = moContext.fetch(predicate).first ?? moContext.insert()
        model.courseId = courseId
        model.id = item.id
        model.title = item.title
        model.position = item.position ?? -1
        model.isHidden = item.hidden ?? false
        model.isReadOnly = item.read_only ?? false
        model.isTeacherNotes = item.teacher_notes ?? false
        return model
    }
}
