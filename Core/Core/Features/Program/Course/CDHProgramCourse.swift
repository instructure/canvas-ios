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

public final class CDHProgramCourse: NSManagedObject {
    @NSManaged public var programID: String
    @NSManaged public var courseID: String
    @NSManaged public var courseName: String
    @NSManaged public var moduleItems: Set<CDHProgramCourseModuleItem>

    @discardableResult
    public static func save(
        _ apiEntity: GetHCoursesByIdsResponse.ProgramCourse?,
        programID: String,
        in context: NSManagedObjectContext
    ) -> CDHProgramCourse {
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "%K == %@", #keyPath(CDHProgramCourse.programID), programID),
            NSPredicate(format: "%K == %@", #keyPath(CDHProgramCourse.courseID), (apiEntity?.id).orEmpty)
        ])

        let dbEntity: CDHProgramCourse = context.fetch(predicate).first ?? context.insert()
        dbEntity.programID = programID
        dbEntity.courseID = (apiEntity?.id).orEmpty
        dbEntity.courseName = (apiEntity?.name).orEmpty

        let moduleItems = (apiEntity?.modulesConnection?.edges ?? [])
            .compactMap { $0.node }
            .compactMap { $0.moduleItems }
            .flatMap { $0 }

        let moduleItemsEntites: [CDHProgramCourseModuleItem] = moduleItems.map { moduleItem in
            CDHProgramCourseModuleItem.save(
                moduleItem,
                courseID: (apiEntity?.id).orEmpty,
                programID: programID,
                in: context
            )
        }
        dbEntity.moduleItems = Set(moduleItemsEntites)
        return dbEntity
    }
}
