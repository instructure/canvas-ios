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

final public class CDHProgramProgress: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var completionPercentage: Double
    @NSManaged public var courseEnrollmentStatus: String
    @NSManaged public var canvasCourseId: String

    @discardableResult
    static func save(
        _ apiEntity: GetHProgramsResponse.Progress,
        in context: NSManagedObjectContext
    ) -> CDHProgramProgress {
        let dbEntity: CDHProgramProgress = context.first(
            where: #keyPath(CDHProgramProgress.id),
            equals: apiEntity.id
        ) ?? context.insert()

        dbEntity.id = apiEntity.id.defaultToEmpty
        dbEntity.completionPercentage = apiEntity.completionPercentage.defaultToZero
        dbEntity.courseEnrollmentStatus = apiEntity.courseEnrollmentStatus.defaultToEmpty
        dbEntity.canvasCourseId = apiEntity.requirement?.dependent?.canvasCourseID ?? ""
        return dbEntity
    }
}
