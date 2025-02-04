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

public final class CDCourseProgression: NSManagedObject, WriteableModel {
    public typealias JSON = GetCoursesProgressionResponse.EnrollmentModel

    // MARK: - Properties
    @NSManaged public var courseID: String
    @NSManaged public var completionPercentage: Double
    @NSManaged public var course: Course
    @NSManaged public var institutionName: String?
    @NSManaged public var incompleteModulesRaw: NSOrderedSet?

    public var incompleteModules: [Module] {
        get { incompleteModulesRaw?.array as? [Module] ?? [] }
        set { incompleteModulesRaw = NSOrderedSet(array: newValue) }
    }

    @discardableResult
    public static func save(
        _ items: [GetCoursesProgressionResponse.EnrollmentModel],
        in context: NSManagedObjectContext
    ) -> [CDCourseProgression] {
        items.map { save($0, in: context) }
    }

    @discardableResult
    public static func save(
        _ enrollmentModel: GetCoursesProgressionResponse.EnrollmentModel,
        in context: NSManagedObjectContext
    ) -> CDCourseProgression {
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
    ) -> CDCourseProgression {

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

        let model: CDCourseProgression =
            context.first(where: #keyPath(CDCourseProgression.courseID), equals: courseId) ?? context.insert()

        model.course = course
        model.courseID = courseId
        model.institutionName = institutionName
        model.completionPercentage = completionPercentage ?? 100.0
        model.incompleteModules = incompleteModules
            .map { Module.save($0, for: courseId, in: context) }
            .compactMap { $0 }

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

extension Module {
    static func save(
        _ item: GetCoursesProgressionResponse.IncompleteNode,
        for courseID: String,
        in context: NSManagedObjectContext
    ) -> Module? {
        guard let responseModule = item.module else { return nil }
        let incompleteItems = item.incompleteItemsConnection?.nodes ?? []

        let predicate = NSPredicate(format: "%K == %@", #keyPath(Module.id), responseModule.id)
        let newModule: Module = context.fetch(predicate).first ?? context.insert()
        let moduleID = responseModule.id

        newModule.id = moduleID
        newModule.courseID = courseID
        newModule.name = responseModule.name
        newModule.position = responseModule.position ?? 0
        newModule.items = incompleteItems.map {
            ModuleItem.save($0, for: courseID, for: moduleID, in: context)
        }

        return newModule
    }
}

extension ModuleItem {
    static func save(
        _ item: GetCoursesProgressionResponse.ModuleContent,
        for courseID: String,
        for moduleID: String,
        in context: NSManagedObjectContext
    ) -> ModuleItem {
        let id = item.id
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(key: #keyPath(ModuleItem.courseID), equals: courseID),
            NSPredicate(key: #keyPath(ModuleItem.id), equals: id)
        ])
        let model: ModuleItem = context.fetch(predicate).first ?? context.insert()
        model.id = id
        model.htmlURL = URL(string: item.url ?? "")
        model.courseID = courseID
        model.moduleID = moduleID

        return model
    }
}
