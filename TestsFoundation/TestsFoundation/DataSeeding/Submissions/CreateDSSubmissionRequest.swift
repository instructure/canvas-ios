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

// https://canvas.instructure.com/doc/api/submissions.html#method.submissions.create
public struct CreateDSSubmissionRequest: APIRequestable {
    public typealias Response = DSSubmission

    public let method = APIMethod.post
    public var path: String
    public let body: Body?

    public init(body: Body, courseId: String, assignmentId: String) {
        self.body = body
        self.path = "courses/\(courseId)/assignments/\(assignmentId)/submissions"
    }
}

extension CreateDSSubmissionRequest {
    public struct RequestedDSSubmission: Encodable {
        let submission_type: SubmissionType
        let body: String
        let user_id: String

        public init(submission_type: SubmissionType, body: String, user_id: String) {
            self.submission_type = submission_type
            self.body = body
            self.user_id = user_id
        }
    }

    public struct Body: Encodable {
        let submission: RequestedDSSubmission
    }
}
