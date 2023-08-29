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

// https://canvas.instructure.com/doc/api/submissions.html#method.submissions_api.update
public struct CreateDSGradesRequest: APIRequestable {
    public typealias Response = APINoContent

    public let method = APIMethod.put
    public var path: String
    public let body: Body?

    public init(body: Body, courseId: String, assignmentId: String, userId: String) {
        self.body = body
        self.path = "courses/\(courseId)/assignments/\(assignmentId)/submissions/\(userId)"
    }
}

extension CreateDSGradesRequest {
    public struct RequestedDSGrade: Encodable {
        let posted_grade: String

        public init(posted_grade: String) {
            self.posted_grade = posted_grade
        }
    }

    public struct RequestedDSComment: Encodable {
        let text_comment: String

        public init(textComment: String? = nil) {
            self.text_comment = textComment ?? "Nice submission!"
        }
    }

    public struct Body: Encodable {
        let submission: RequestedDSGrade
        let comment: RequestedDSComment
    }
}
