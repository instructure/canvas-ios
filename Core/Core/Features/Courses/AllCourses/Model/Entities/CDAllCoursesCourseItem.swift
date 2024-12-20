//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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
import Combine

public final class CDAllCoursesCourseItem: NSManagedObject {
    @NSManaged public var courseId: String
    @NSManaged public var courseCode: String
    /** The enrollment state which was passed to the API when this entity was returned. Used to group courses into past, current and future sections. */
    @NSManaged public var enrollmentState: String
    @NSManaged public var isFavorite: Bool
    @NSManaged public var isPublished: Bool
    @NSManaged public var isFavoriteButtonVisible: Bool
    /** Indicates if tapping on this course should load course details or the cell should be disabled. */
    @NSManaged public var isCourseDetailsAvailable: Bool
    @NSManaged public var name: String
    /** A comma separated list of enrollments eg: "Student, Teacher". */
    @NSManaged public var roles: String
    @NSManaged public var termName: String?

    @discardableResult
    public static func save(_ apiEntity: APICourse,
                            enrollmentState: GetCoursesRequest.EnrollmentState,
                            app: AppEnvironment.App? = AppEnvironment.shared.app,
                            in context: NSManagedObjectContext) -> CDAllCoursesCourseItem {
        let dbEntity: CDAllCoursesCourseItem = context.first(where: #keyPath(CDAllCoursesCourseItem.courseId),
                                                     equals: apiEntity.id.value)
                                       ?? context.insert()
        dbEntity.courseId = apiEntity.id.value
        dbEntity.courseCode = apiEntity.course_code ?? ""
        dbEntity.enrollmentState = enrollmentState.rawValue
        dbEntity.isFavorite = apiEntity.is_favorite ?? false
        dbEntity.isPublished = apiEntity.workflow_state == .available || apiEntity.workflow_state == .completed
        dbEntity.name = apiEntity.name ?? apiEntity.course_code ?? ""
        dbEntity.roles = apiEntity.enrollments.roles
        dbEntity.termName = apiEntity.term?.name
        dbEntity.isFavoriteButtonVisible = isFavoriteButtonVisible(enrollmentState: enrollmentState,
                                                                   app: app,
                                                                   workflowState: apiEntity.workflow_state)
        dbEntity.isCourseDetailsAvailable = !(app == .student && apiEntity.workflow_state == .unpublished)
        return dbEntity
    }

    public static func isFavoriteButtonVisible(enrollmentState: GetCoursesRequest.EnrollmentState,
                                               app: AppEnvironment.App?,
                                               workflowState: CourseWorkflowState?) -> Bool {
        guard enrollmentState == .active else {
            return false
        }

        if app == .teacher {
            return workflowState == .unpublished || workflowState == .available
        } else if app == .student {
            return workflowState == .available
        }

        return false
    }
}

extension Optional where Wrapped == [APIEnrollment] {
    var roles: String {
        var roles = (self ?? [])
            .filter {
                $0.enrollment_state != .deleted
            }
            .compactMap {
                Role(rawValue: $0.role)?.description()
            }
        roles = Array(Set(roles)).sorted()
        return roles.joined(separator: ", ")
    }
}

public extension Array where Element == CDAllCoursesCourseItem {

    func filter(query: String) -> Future<[CDAllCoursesCourseItem], Error> {
        Future<[CDAllCoursesCourseItem], Error> { promise in
            if query.isEmpty {
                return promise(.success(self))
            }

            let filteredItems = filter {
                $0.name.lowercased().contains(query) || $0.courseCode.lowercased().contains(query)
            }
            promise(.success(filteredItems))
        }
    }
}

public extension Publisher where Output == [CDAllCoursesCourseItem], Failure == Error {

    func filter<Query: Publisher>(with query: Query) -> AnyPublisher<Output, Failure>
        where Query.Output == String, Query.Failure == Failure {
        Publishers
            .CombineLatest(self, query.map { $0.lowercased() })
            .flatMap { (items, searchQuery) in
                items.filter(query: searchQuery)
            }
            .eraseToAnyPublisher()
    }
}
