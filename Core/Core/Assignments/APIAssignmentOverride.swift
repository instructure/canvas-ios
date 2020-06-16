//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
    let student_ids: [ID]?
    let group_id: ID?
    let course_section_id: ID?
    let title: String
    let due_at: Date?
    let all_day: Bool?
    let all_day_date: Bool?
    let unlock_at: Date?
    let lock_at: Date?
}

// https://canvas.instructure.com/doc/api/assignments.html#method.assignment_overrides.create
struct CreateAssignmentOverrideRequest: APIRequestable {
    typealias Response = APIAssignmentOverride
    struct Body: Codable, Equatable {
        struct AssignmentOverride: Codable, Equatable {
            let title: String
        }

        let assignment_override: AssignmentOverride
    }

    let courseID: String
    let assignmentID: String

    let body: Body?
    let method = APIMethod.post
    var path: String {
        let context = Context(.course, id: courseID)
        return "\(context.pathComponent)/assignments/\(assignmentID)/overrides"
    }
}
