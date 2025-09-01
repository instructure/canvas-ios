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

final public class CDHProgram: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var programDescription: String?
    @NSManaged public var variant: String
    @NSManaged public var porgresses: Set<CDHProgramProgress>
    @NSManaged public var requirements: Set<CDHProgramRequirement>
    @NSManaged public var courseCompletionCount: NSNumber?
    @NSManaged public var startDate: Date?
    @NSManaged public var endDate: Date?

  @discardableResult
   public static func save(
        _ apiEntity: GetHProgramsResponse.EnrolledProgram,
        in context: NSManagedObjectContext
    ) -> CDHProgram {
        let dbEntity: CDHProgram = context.first(
            where: #keyPath(CDHProgram.id),
            equals: apiEntity.id
        ) ?? context.insert()

        dbEntity.id = apiEntity.id.orEmpty
        dbEntity.name = apiEntity.name.orEmpty
        dbEntity.programDescription = apiEntity.description
        dbEntity.variant = apiEntity.variant.orEmpty
        dbEntity.courseCompletionCount = apiEntity.courseCompletionCount as NSNumber?
        dbEntity.startDate = apiEntity.startDate
        dbEntity.endDate = apiEntity.endDate
        if let progresses = apiEntity.progresses {
            let progressesEntities: [CDHProgramProgress] = progresses.map { apiItem in
                return CDHProgramProgress.save(apiItem, in: context)
            }
            dbEntity.porgresses = Set(progressesEntities)
        } else {
            dbEntity.porgresses = []
        }

        if let requirements = apiEntity.requirements {
            let requirementsEntities: [CDHProgramRequirement] = requirements.map { apiItem in
                return CDHProgramRequirement.save(apiItem, in: context)
            }
            dbEntity.requirements = Set(requirementsEntities)
        } else {
            dbEntity.requirements = []
        }
        return dbEntity
    }
}
