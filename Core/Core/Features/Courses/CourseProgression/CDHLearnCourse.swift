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

public final class CDHLearnCourse: NSManagedObject, WriteableModel {
    public typealias JSON = GetCoursesProgressionResponse.EnrollmentModel

    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var enrollmentId: String

    @discardableResult
    public static func save(
        _ items: [GetCoursesProgressionResponse.EnrollmentModel],
        in context: NSManagedObjectContext
    ) -> [CDHLearnCourse] {
        items.map { save($0, in: context) }
    }

    @discardableResult
    public static func save(
        _ enrollmentModel: GetCoursesProgressionResponse.EnrollmentModel,
        in context: NSManagedObjectContext
    ) -> CDHLearnCourse {
        let course = enrollmentModel.course

        let entity: CDHLearnCourse = context.first(where: #keyPath(CDHLearnCourse.id), equals: course.id) ?? context.insert()
        entity.id = course.id
        entity.name = course.name
        entity.enrollmentId = enrollmentModel.id
        return entity
    }
}
