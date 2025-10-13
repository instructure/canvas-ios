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

public final class CDHScoresCourseSettings: NSManagedObject {
    @NSManaged public var restrictQuantitativeData: Bool
    @NSManaged public var course: CDHScoresCourse

    @discardableResult
    static func save(
        _ item: APICourseSettings,
        course: CDHScoresCourse,
        in context: NSManagedObjectContext
    ) -> CDHScoresCourseSettings {
        let entity: CDHScoresCourseSettings = {
            if let settings: CDHScoresCourseSettings = context.first(
                where: #keyPath(CDHScoresCourseSettings.course.courseID),
                equals: course.courseID
            ) {
                return settings
            }

            let settings: CDHScoresCourseSettings = context.insert()
            settings.restrictQuantitativeData = false
            return settings
        }()

        if let restrict_quantitative_data = item.restrict_quantitative_data, AppEnvironment.shared.app != .teacher {
            entity.restrictQuantitativeData = restrict_quantitative_data
        }

        entity.course = course

        return entity
    }
}
