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

public final class CDCourse: NSManagedObject, WriteableModel {
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

    @NSManaged public var nextModuleName: String?
    @NSManaged public var nextModuleItemName: String?
    @NSManaged public var nextModuleItemType: String?
    @NSManaged public var nextModuleItemDueDate: Date?
    @NSManaged public var nextModuleItemEstimatedTime: String?
    @NSManaged public var nextModuleItemURL: String?

    @discardableResult
    public static func save(
        _ items: [GetCoursesProgressionResponse.EnrollmentModel],
        in context: NSManagedObjectContext
    ) -> [CDCourse] {
        items.map { save($0, in: context) }
    }

    @discardableResult
    public static func save(
        _ enrollmentModel: GetCoursesProgressionResponse.EnrollmentModel,
        in context: NSManagedObjectContext
    ) -> CDCourse {
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
    ) -> CDCourse {
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

        let model: CDCourse =
            context.first(where: #keyPath(CDCourse.courseID), equals: courseId) ?? context.insert()

        model.course = course
        model.courseID = courseId
        model.institutionName = institutionName
        model.state = enrollmentModel.state
        model.enrollmentID = enrollmentModel.id
        model.completionPercentage = completionPercentage ?? 0.0

        // If this is a completed course, return early
        if completionPercentage == 100 {
            model.nextModuleID = nil
            model.nextModuleItemID = nil
            model.nextModuleItemEstimatedTime = nil
            model.nextModuleItemType = nil
            model.nextModuleItemDueDate = nil
            model.nextModuleName = nil
            model.nextModuleItemURL = nil
            model.nextModuleItemName = nil
            return model
        }

        // Find the next modules connection
        let nextModuleConnection = incompleteModules.first
        let nextModule = nextModuleConnection?.module

        // Find the next module item within a module connection
        let nextModuleItem = nextModuleConnection?.incompleteItemsConnection?.nodes.first
        let hasNextModuleItem = nextModule != nil && nextModuleItem != nil

        // If the user has not started the course yet, "incompleteItemsConnection" will be null.
        // Try to set the first module item from "modulesConnection".
        if !hasNextModuleItem || completionPercentage == nil {
            let node = enrollmentModel.course.modulesConnection?.edges?.first?.node
            if let firstItem = node?.moduleItems?.first {
                model.nextModuleID = node?.id
                model.nextModuleItemID = firstItem.content?.id
                model.nextModuleItemEstimatedTime = firstItem.estimatedDuration
                model.nextModuleItemType = firstItem.content?.__typename
                model.nextModuleItemDueDate = firstItem.content?.dueAt
                model.nextModuleName = node?.name
                model.nextModuleItemURL = firstItem.url
                model.nextModuleItemName = firstItem.content?.title
            } else {
                model.nextModuleID = nil
                model.nextModuleItemID = nil
                model.nextModuleItemEstimatedTime = nil
                model.nextModuleItemType = nil
                model.nextModuleItemDueDate = nil
                model.nextModuleName = nil
                model.nextModuleItemURL = nil
                model.nextModuleItemName = nil
            }
            // If user has already started the course, set the module from "incompleteModuleItemsConnections"
        } else {
            model.nextModuleID = nextModule?.id
            model.nextModuleItemID = nextModuleItem?.id
            model.nextModuleItemEstimatedTime = nextModuleItem?.estimatedDuration
            model.nextModuleItemType = nextModuleItem?.content?.__typename
            model.nextModuleItemDueDate = nextModuleItem?.content?.dueAt
            model.nextModuleName = nextModule?.name
            model.nextModuleItemURL = nextModuleItem?.url
            model.nextModuleItemName = nextModuleItem?.content?.title
        }
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
        return course
    }
}
