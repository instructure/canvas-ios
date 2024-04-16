//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

/**
 This object stores the courses to be shown/hidden in the calendar's course filter menu. This is a single object in the DB.
 */
class Planner: NSManagedObject {
    @NSManaged var studentID: String?
    @NSManaged var availableCourseIDs: [String]
    @NSManaged var hiddenCourseIDs: [String]

    var selectedCourses: Set<String> {
        get {
            Set(availableCourseIDs).subtracting(hiddenCourseIDs)
        }
        set {
            hiddenCourseIDs = Array(Set(availableCourseIDs).subtracting(newValue))
        }
    }

    var allSelected: Bool {
        availableCourseIDs.allSatisfy { selectedCourses.contains($0) }
    }

    override func awakeFromInsert() {
        super.awakeFromInsert()

        // These properties aren't optional in CoreData so we have to setup an initial
        // value after the object's creation otherwise CoreData will throw an error
        hiddenCourseIDs = []
        availableCourseIDs = []
    }
}
