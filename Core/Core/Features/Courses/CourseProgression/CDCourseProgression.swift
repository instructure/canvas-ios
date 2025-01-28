//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import Foundation
import CoreData


// TODO: Rename to CDEnrollment
public final class CDCourseProgression: NSManagedObject, WriteableModel {
    public typealias JSON = GetCoursesProgressionResponse.EnrollmentModel

    // MARK: - Properties
    @NSManaged public var courseID: String
    @NSManaged public var courseName: String?
    @NSManaged public var imageUrl: String?
    @NSManaged public var overviewDescription: String?
    @NSManaged public var completionPercentage: Double

    @discardableResult
    public static func save(
        _ item: GetCoursesProgressionResponse.EnrollmentModel,
        in context: NSManagedObjectContext
    ) -> CDCourseProgression {
        let itemCourse = item.course
        let courseId = itemCourse.id
        var image: URL?
        if let imageUrl = item.course.imageUrl {
            image = URL(string: imageUrl)
        }

        let course: Course = context.first(where: #keyPath(Course.id), equals: courseId) ?? context.insert()
        course.id = courseId
        course.name = item.course.name
        course.imageDownloadURL = image
        course.syllabusBody = item.course.syllabusBody

        itemCourse.modulesConnection?.nodes?.forEach { module in
            let newModule: Module = context.first(where: #keyPath(Module.id), equals: module.id) ?? context.insert()
            newModule.id = module.id
            newModule.name = module.name
            newModule.position = module.position ?? 0
            newModule.courseID = courseId

            module.moduleItems?.forEach { moduleItem in
                let content = moduleItem.content

                let newModuleItem: ModuleItem = context.first(where: #keyPath(ModuleItem.id), equals: content.id) ?? context.insert()
                newModuleItem.id = content.id
                newModuleItem.courseID = courseId
            }
        }

        let model: CDCourseProgression = context.first(where: #keyPath(CDCourseProgression.courseID), equals: courseId) ?? context.insert()

        model.courseID = courseId
        model.completionPercentage = item
            .course
            .usersConnection?
            .nodes?
            .first?
            .courseProgression?
            .requirements?
            .completionPercentage ?? 0.0
        return model
    }
}
