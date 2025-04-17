//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import Core

// https://canvas.instructure.com/doc/api/assignment_groups.html#method.assignment_groups_api.create
public struct CreateDSAssignmentGroupRequest: APIRequestable {
    public typealias Response = DSAssignmentGroup

    public let method = APIMethod.post
    public let path: String
    public let body: Body?

    public init(body: Body, course: DSCourse) {
        self.body = body
        self.path = "courses/\(course.id)/assignment_groups"
    }
}

extension CreateDSAssignmentGroupRequest {
    public struct Body: Encodable {
        let assignments: [DSAssignment?]
        let name: String
        let group_weight: Float?

        public init(
            assignments: [DSAssignment?] = [],
            name: String = "Sample AG",
            group_weight: Float? = nil
        ) {
            self.assignments = assignments
            self.name = name
            self.group_weight = group_weight
        }
    }
}
