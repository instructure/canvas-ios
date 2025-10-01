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

public struct APIModuleItemAssignmentInfo: Codable, Equatable {
    let points_possible: Double?
    let due_date: Date?
    let past_due: Bool?
    let todo_date: Date?
    let sub_assignments: [APISubAssignment]?
}

extension APIModuleItemAssignmentInfo {
    struct APISubAssignment: Codable, Equatable {
        let sub_assignment_tag: String
        let replies_required: Int?
        let points_possible: Double?
        let due_date: Date?
    }
}

#if DEBUG

extension APIModuleItemAssignmentInfo {
    static func make(
        points_possible: Double? = nil,
        due_date: Date? = nil,
        past_due: Bool? = nil,
        todo_date: Date? = nil,
        sub_assignments: [APISubAssignment]? = nil
    ) -> APIModuleItemAssignmentInfo {
        APIModuleItemAssignmentInfo(
            points_possible: points_possible,
            due_date: due_date,
            past_due: past_due,
            todo_date: todo_date,
            sub_assignments: sub_assignments
        )
    }
}

extension APIModuleItemAssignmentInfo.APISubAssignment {
    static func make(
        sub_assignment_tag: String = "",
        replies_required: Int? = nil,
        points_possible: Double? = nil,
        due_date: Date? = nil
    ) -> APIModuleItemAssignmentInfo.APISubAssignment {
        APIModuleItemAssignmentInfo.APISubAssignment(
            sub_assignment_tag: sub_assignment_tag,
            replies_required: replies_required,
            points_possible: points_possible,
            due_date: due_date
        )
    }
}

#endif
