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

public final class CDScoresCourseEnrollment: NSManagedObject {
    @NSManaged public var courseID: String
    @NSManaged public var score: NSNumber?
    @NSManaged public var grade: String?

    @discardableResult
    public static func save(
        courseID: String,
        apiEntity: APIEnrollment,
        in context: NSManagedObjectContext
    ) -> CDScoresCourseEnrollment {
        let dbEntity: CDScoresCourseEnrollment = context.first(
            where: #keyPath(CDScoresCourseEnrollment.courseID),
            equals: courseID
        ) ?? context.insert()
        dbEntity.courseID = courseID
        dbEntity.grade = apiEntity.computed_current_grade
        if let score = apiEntity.computed_current_score {
            dbEntity.score = NSNumber(value: score)
        }
        return dbEntity
    }

    public func update(
        courseID: String,
        apiEntity: APIEnrollment,
        in context: NSManagedObjectContext
    ) {
        let dbEntity: CDScoresCourseEnrollment = context.first(
            where: #keyPath(CDScoresCourseEnrollment.courseID),
            equals: courseID
        ) ?? context.insert()
        dbEntity.courseID = courseID
        dbEntity.grade = apiEntity.computed_current_grade
        if let score = apiEntity.computed_current_score {
            dbEntity.score = NSNumber(value: score)
        }
    }
}
