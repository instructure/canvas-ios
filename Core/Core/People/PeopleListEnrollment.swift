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

import Foundation
import CoreData

final public class PeopleListEnrollment: NSManagedObject {
    @NSManaged public var id: String?
    @NSManaged public var canvasContextID: String?
    @NSManaged public var role: String?
    @NSManaged public var roleID: String?
    @NSManaged public var stateRaw: String?
    @NSManaged public var userID: String?
    @NSManaged public var type: String
    @NSManaged public var course: Course?
    @NSManaged public var courseSectionID: String?
    @NSManaged public var observedUser: PeopleListUser?
}

extension PeopleListEnrollment {
    public var state: EnrollmentState {
        get { return EnrollmentState(rawValue: stateRaw ?? "") ?? .inactive }
        set { stateRaw = newValue.rawValue }
    }

    public var isStudent: Bool {
        return type.lowercased().contains("student")
    }

    public var isTeacher: Bool {
        return type.lowercased().contains("teacher")
    }

    public var isTA: Bool {
        return type.lowercased().contains("ta")
    }

    /// The localized, human-readable `role` or the custom role
    public var formattedRole: String? {
        guard let role = role else { return nil }
        return Role(rawValue: role)?.description()
    }
}

extension PeopleListEnrollment {
    func update(fromApiModel item: APIEnrollment, course: Course?, gradingPeriodID: String? = nil, in client: NSManagedObjectContext) {
        id = item.id?.value
        role = item.role
        roleID = item.role_id
        state = item.enrollment_state
        type = item.type
        userID = item.user_id.value
        courseSectionID = item.course_section_id?.value

        let courseID = item.course_id?.value ?? course?.id
        if let courseID = courseID {
            canvasContextID = "course_\(courseID)"
        }

        if let apiObservedUser = item.observed_user {
            let observedUserModel = PeopleListUser.save(apiObservedUser, courseId: courseID, in: client)
            observedUser = observedUserModel
        } else {
            observedUser = nil
        }
    }
}
