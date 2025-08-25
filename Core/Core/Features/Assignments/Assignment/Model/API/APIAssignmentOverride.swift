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
    let assignment_id: ID
    let course_section_id: ID?
    let due_at: Date?
    let group_id: ID?
    let id: ID
    let lock_at: Date?
    let student_ids: [ID]?
    let title: String
    let unlock_at: Date?
}

#if DEBUG

extension APIAssignmentOverride {
    public func make(
        assignment_id: ID,
        course_section_id: ID?,
        due_at: Date?,
        group_id: ID?,
        id: ID,
        lock_at: Date?,
        student_ids: [ID]?,
        title: String,
        unlock_at: Date?
    ) -> APIAssignmentOverride {
        APIAssignmentOverride(
            assignment_id: assignment_id,
            course_section_id: course_section_id,
            due_at: due_at,
            group_id: group_id,
            id: id,
            lock_at: lock_at,
            student_ids: student_ids,
            title: title,
            unlock_at: unlock_at
        )
    }
}

#endif
