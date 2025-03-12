//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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
import Foundation

// https://canvas.instructure.com/doc/api/assignments.html#method.assignments_api.create
public struct CreateDSAssignmentRequest: APIRequestable {
    public typealias Response = DSAssignment

    public let method = APIMethod.post
    public let path: String
    public let body: Body?

    public init(body: Body, courseId: String) {
        self.body = body
        self.path = "courses/\(courseId)/assignments"
    }
}

extension CreateDSAssignmentRequest {
    public struct RequestedDSAssignment: Encodable {
        let name: String
        let description: String?
        let published: Bool
        let submission_types: [SubmissionType]
        let points_possible: Float?
        let grading_type: GradingType?
        let due_at: Date?
        let lock_at: Date?
        let unlock_at: Date?
        let assignment_group_id: String?
        let allowed_extensions: [String]?

        public init(name: String = "Assignment Name",
                    description: String? = nil,
                    published: Bool = true,
                    submission_types: [SubmissionType] = [.online_text_entry],
                    points_possible: Float? = nil,
                    grading_type: GradingType? = nil,
                    due_at: Date? = nil,
                    lock_at: Date? = nil,
                    unlock_at: Date? = nil,
                    assignment_group_id: String? = nil,
                    allowed_extensions: [String]? = nil) {
            self.name = name
            self.description = description
            self.published = published
            self.submission_types = submission_types
            self.points_possible = points_possible
            self.grading_type = grading_type
            self.due_at = due_at
            self.lock_at = lock_at
            self.unlock_at = unlock_at
            self.assignment_group_id = assignment_group_id
            self.allowed_extensions = allowed_extensions
        }
    }

    public struct Body: Encodable {
        let assignment: RequestedDSAssignment
    }
}
