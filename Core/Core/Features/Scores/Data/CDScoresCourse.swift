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

public final class CDScoresCourse: NSManagedObject {
    @NSManaged public var courseID: String
    @NSManaged public var hideFinalGrade: Bool
    @NSManaged public var enrollments: Set<CDScoresCourseEnrollment>
    @NSManaged public var settings: CDScoresCourseSettings?

    @discardableResult
    public static func save(
        _ apiEntity: APICourse,
        in context: NSManagedObjectContext
    ) -> CDScoresCourse {
        let dbEntity: CDScoresCourse = context.first(
            where: #keyPath(CDScoresCourse.courseID),
            equals: apiEntity.id.value
        ) ?? context.insert()
        dbEntity.courseID = apiEntity.id.value

        if let apiEnrollments = apiEntity.enrollments {
            let enrollmentEntities: [CDScoresCourseEnrollment] = apiEnrollments.map { apiItem in
                /// This enrollment contains the grade fields necessary to calculate grades on the dashboard.
                /// This is a special enrollment that has no courseID nor enrollmentID and contains no Grade objects.
                let enrollment = CDScoresCourseEnrollment.save(
                    courseID: dbEntity.courseID,
                    apiEntity: apiItem,
                    in: context
                )
                return enrollment
            }
            dbEntity.enrollments = Set(enrollmentEntities)
        } else {
            dbEntity.enrollments = []
        }

        if let apiSettings = apiEntity.settings {
            let settingsEntity = CDScoresCourseSettings.save(
                apiSettings,
                course: dbEntity,
                in: context
            )
            dbEntity.settings = settingsEntity
        }

        dbEntity.hideFinalGrade = apiEntity.hide_final_grades ?? false

        return dbEntity
    }
}
