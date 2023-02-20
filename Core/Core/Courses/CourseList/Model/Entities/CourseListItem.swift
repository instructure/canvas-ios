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

public final class CourseListItem: NSManagedObject {
    @NSManaged public var courseId: String
    @NSManaged public var courseCode: String
    /** The enrollment state which was passed to the API when this entity was returned. Used to group courses into past, current and future sections. */
    @NSManaged public var enrollmentState: String
    @NSManaged public var isFavorite: Bool
    @NSManaged public var isPublished: Bool
    @NSManaged public var isFavoriteButtonVisible: Bool
    @NSManaged public var name: String
    /** A comma separated list of enrollments eg: "Student, Teacher". */
    @NSManaged public var roles: String
    @NSManaged public var termName: String?

    @discardableResult
    public static func save(_ apiEntity: APICourse,
                            enrollmentState: GetCoursesRequest.EnrollmentState,
                            in context: NSManagedObjectContext) -> CourseListItem {
        let dbEntity: CourseListItem = context.first(where: #keyPath(CourseListItem.courseId),
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
        dbEntity.isFavoriteButtonVisible = apiEntity.workflow_state.isFavoriteButtonVisible && enrollmentState.isFavoriteButtonVisible

        return dbEntity
    }
}

private extension Optional where Wrapped == CourseWorkflowState {
    var isFavoriteButtonVisible: Bool {
        switch self {
        case .available, .completed: return true
        case nil, .unpublished, .deleted: return false
        }
    }
}

private extension GetCoursesRequest.EnrollmentState {
    var isFavoriteButtonVisible: Bool {
        switch self {
        case .active: return true
        case .completed, .invited_or_pending: return false
        }
    }
}

private extension Optional where Wrapped == [APIEnrollment] {
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
