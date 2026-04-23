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
    @NSManaged public var enrolledUser: PeopleListUser?
}

extension PeopleListEnrollment {
    /// The localized, human-readable `role` or the custom role
    public var formattedRole: String? {
        guard let role = role else { return nil }
        return Role(rawValue: role)?.description()
    }
}

extension PeopleListEnrollment {
    func update(fromApiModel item: APIEnrollment, user: PeopleListUser, gradingPeriodID: String? = nil, in client: NSManagedObjectContext) {
        id = item.id?.value
        role = item.role
        enrolledUser = user

        if let courseID = item.course_id?.value {
            canvasContextID = "course_\(courseID)"
        }
    }
}
