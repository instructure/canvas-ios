//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import CoreData

final public class Enrollment: NSManagedObject {
    @NSManaged public var canvasContextID: String?
    @NSManaged public var roleRaw: String?
    @NSManaged public var roleID: String?
    @NSManaged public var stateRaw: String?
    @NSManaged public var typeRaw: String?
    @NSManaged public var userID: String?
    @NSManaged public var course: Course?
}

extension Enrollment {

    public var role: EnrollmentRole? {
        get { return EnrollmentRole(rawValue: roleRaw ?? "")  }
        set { roleRaw = newValue?.rawValue }
    }

    public var state: EnrollmentState {
        get { return EnrollmentState(rawValue: stateRaw ?? "") ?? .inactive }
        set { stateRaw = newValue.rawValue }
    }
}

extension Enrollment {
    func update(fromApiModel item: APIEnrollment, course: Course?, in client: PersistenceClient) throws {
        role =  EnrollmentRole(rawValue: item.role)
        roleID = item.role_id
        state = item.enrollment_state
        userID = item.user_id
        self.course = course
        if let course = course {
            canvasContextID = "course_\(course.id)"
        }
    }
}

public extension Set where Element: Enrollment {
    func hasRole(_ role: EnrollmentRole) -> Bool {
        return self.filter { $0.role == role }.count > 0
    }
}
