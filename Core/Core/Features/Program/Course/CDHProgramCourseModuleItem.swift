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

public final class CDHProgramCourseModuleItem: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var courseID: String
    @NSManaged public var programID: String
    @NSManaged public var estimatedDuration: String?

    @discardableResult
    public static func save(
        _ apiEntity: GetHProgramCourseResponse.ModuleItem,
        courseID: String,
        programID: String,
        in context: NSManagedObjectContext
    ) -> CDHProgramCourseModuleItem {
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "%K == %@", #keyPath(CDHProgramCourseModuleItem.id), apiEntity.id.orEmpty),
            NSPredicate(format: "%K == %@", #keyPath(CDHProgramCourseModuleItem.courseID), courseID),
            NSPredicate(format: "%K == %@", #keyPath(CDHProgramCourseModuleItem.programID), programID)
        ])

        let dbEntity: CDHProgramCourseModuleItem = context.fetch(predicate).first ?? context.insert()
        dbEntity.id = apiEntity.id.orEmpty
        dbEntity.courseID = courseID
        dbEntity.programID = programID
        dbEntity.estimatedDuration = apiEntity.published == true ? apiEntity.estimatedDuration : nil
        return dbEntity
    }
}
