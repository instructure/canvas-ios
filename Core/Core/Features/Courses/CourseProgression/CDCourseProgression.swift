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


public final class CDCourseProgression: NSManagedObject, WriteableModel {
    public typealias JSON = GetCoursesProgressionResponse.EnrollmentModel

    // MARK: - Properties
    @NSManaged public var completionPercentage: Double
    @NSManaged public var course: Course
    @NSManaged public var courseID: String
    @NSManaged public var modulesRaw: NSOrderedSet?
    @NSManaged private var incompleteModulesRaw: NSOrderedSet?

    public var modules: [Module] {
        get { modulesRaw?.array as? [Module] ?? [] }
        set { modulesRaw = NSOrderedSet(array: newValue) }
    }

    public var incompleteModules: [Module] {
        get { incompleteModulesRaw?.array as? [Module] ?? [] }
        set { incompleteModulesRaw = NSOrderedSet(array: newValue) }
    }

    @NSManaged public var institutionName: String?

    @discardableResult
    public static func save(
        _ items: [GetCoursesProgressionResponse.EnrollmentModel],
        in context: NSManagedObjectContext
    ) -> [CDCourseProgression] {
        items.map { save($0, in: context) }
    }

    @discardableResult
    public static func save(
        _ item: GetCoursesProgressionResponse.EnrollmentModel,
        in context: NSManagedObjectContext
    ) -> CDCourseProgression {
        let itemCourse = item.course
        let courseId = itemCourse.id
        let courseProgression = itemCourse
            .usersConnection?
            .nodes?
            .first?
            .courseProgression

        var image: URL?
        if let imageUrl = item.course.imageUrl {
            image = URL(string: imageUrl)
        }

        let course: Course = context.first(where: #keyPath(Course.id), equals: courseId) ?? context.insert()
        course.id = courseId
        course.name = item.course.name
        course.imageDownloadURL = image //imageDownloadURL or bannerImageDownloadURL?
        course.syllabusBody = item.course.syllabusBody

        let model: CDCourseProgression = context.first(where: #keyPath(CDCourseProgression.courseID), equals: courseId) ?? context.insert()

        model.modules = itemCourse.modulesConnection?.nodes.map { module in
            Module.save(module.asIncompleteModule, forCourse: courseId, in: context)
        } ?? []

        model.incompleteModules = courseProgression?.incompleteModulesConnection?.nodes?.map { node in
            Module.save(node, forCourse: courseId, in: context)
        } ?? []

        model.course = course
        model.courseID = courseId
        model.institutionName = itemCourse.account?.name
        model.completionPercentage = courseProgression?
            .requirements?
            .completionPercentage ?? 0.0

        return model
    }
}

extension Module {
    static func save(_ item: GetCoursesProgressionResponse.IncompleteModule, forCourse courseID: String, in context: NSManagedObjectContext) -> Module {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(Module.id), item.id)
        let module: Module = context.fetch(predicate).first ?? context.insert()
        module.id = item.id
        module.name = item.name
        module.position = item.position ?? 0
        module.courseID = courseID
        module.prerequisiteModuleIDsRaw = ""
        return module
    }
}

extension GetCoursesProgressionResponse.Module {
    var asIncompleteModule: GetCoursesProgressionResponse.IncompleteModule {
        .init(
            id: id,
            name: name,
            position: position
        )
    }
}
