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

import CoreData
import Foundation

public final class CDDashboardCourse: NSManagedObject, WriteableModel {
    public typealias JSON = GetCoursesProgressionResponse.EnrollmentModel

    // MARK: - Properties
    @NSManaged public var courseID: String
    @NSManaged public var completionPercentage: Double
    @NSManaged public var state: String
    @NSManaged public var enrollmentID: String
    @NSManaged public var course: Course
    @NSManaged public var institutionName: String?
    @NSManaged public var incompleteModulesRaw: NSOrderedSet?
    @NSManaged public var nextModuleItemID: String?
    @NSManaged public var nextModuleID: String?

    @discardableResult
    public static func save(
        _ items: [GetCoursesProgressionResponse.EnrollmentModel],
        in context: NSManagedObjectContext
    ) -> [CDDashboardCourse] {
        items.map { save($0, in: context) }
    }

    @discardableResult
    public static func save(
        _ enrollmentModel: GetCoursesProgressionResponse.EnrollmentModel,
        in context: NSManagedObjectContext
    ) -> CDDashboardCourse {
        let enrollmentModelCourse = enrollmentModel.course
        let courseId = enrollmentModelCourse.id

        let course = saveCourse(
            enrollmentModelCourse: enrollmentModelCourse,
            id: courseId,
            in: context
        )

        return saveCourseProgression(
            enrollmentModel: enrollmentModel,
            course: course,
            in: context
        )
    }

    // MARK: - Private

    private static func saveCourseProgression(
        enrollmentModel: GetCoursesProgressionResponse.EnrollmentModel,
        course: Course,
        in context: NSManagedObjectContext
    ) -> CDDashboardCourse {

        let courseId = enrollmentModel.course.id
        let institutionName = enrollmentModel.course.account?.name
        let courseProgression = enrollmentModel
            .course
            .usersConnection?
            .nodes?
            .first?
            .courseProgression
        let completionPercentage = courseProgression?
            .requirements?
            .completionPercentage

        let incompleteModules =
            courseProgression?
            .incompleteModulesConnection?
            .nodes ?? []

        let model: CDDashboardCourse =
            context.first(where: #keyPath(CDDashboardCourse.courseID), equals: courseId) ?? context.insert()

        model.course = course
        model.courseID = courseId
        model.institutionName = institutionName
        model.completionPercentage = completionPercentage ?? 100.0
        let nextModule = incompleteModules.first?.module
        let nextModuleItem = incompleteModules.first?.incompleteItemsConnection?.nodes.first
        model.nextModuleID = nextModule?.id
        model.nextModuleItemID = nextModuleItem?.id
        model.state = enrollmentModel.state
        model.enrollmentID = enrollmentModel.id
        return model
    }

    private static func saveCourse(
        enrollmentModelCourse: GetCoursesProgressionResponse.CourseModel,
        id courseId: String,
        in context: NSManagedObjectContext
    ) -> Course {
        let course: Course = context.first(where: #keyPath(Course.id), equals: courseId) ?? context.insert()
        course.id = courseId
        course.name = enrollmentModelCourse.name
        course.syllabusBody = enrollmentModelCourse.syllabusBody
        return course
    }
}
