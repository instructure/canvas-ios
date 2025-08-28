//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

// https://canvas.instructure.com/doc/api/assignments.html#AssignmentOverride
public struct APIAssignmentOverride: Codable, Equatable {
    let id: ID
    let assignment_id: ID
    let title: String

    // Targets
    let course_section_id: ID?
    let group_id: ID?
    let student_ids: [ID]?

    // Dates
    let due_at: Date?
    let unlock_at: Date?
    let lock_at: Date?
}

#if DEBUG

extension APIAssignmentOverride {
    public static func make(
        id: String = "",
        assignment_id: String = "",
        title: String = "",
        course_section_id: String? = nil,
        group_id: String? = nil,
        student_ids: [String]? = nil,
        due_at: Date? = nil,
        unlock_at: Date? = nil,
        lock_at: Date? = nil
    ) -> APIAssignmentOverride {
        APIAssignmentOverride(
            id: ID(id),
            assignment_id: ID(assignment_id),
            title: title,
            course_section_id: ID(course_section_id),
            group_id: ID(group_id),
            student_ids: student_ids?.map { ID($0) },
            due_at: due_at,
            unlock_at: unlock_at,
            lock_at: lock_at
        )
    }
}

#endif
