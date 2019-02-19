//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

// https://canvas.instructure.com/doc/api/submissions.html#method.submissions_api.show
public struct GetSubmissionRequest: APIRequestable {
    public typealias Response = APISubmission

    let context: Context
    let assignmentID: String
    let userID: String

    public var path: String {
        return "\(context.pathComponent)/assignments/\(assignmentID)/submissions/\(userID)"
    }

    public var query: [APIQueryItem] {
        return [ .array("include", [ "submission_history" ]) ]
    }
}

// https://canvas.instructure.com/doc/api/submissions.html#method.submissions.create
public struct CreateSubmissionRequest: APIRequestable {
    public typealias Response = APISubmission
    public struct Body: Codable, Equatable {
        struct Submission: Codable, Equatable {
            let text_comment: String?
            let submission_type: SubmissionType
            let body: String? // Requires submission_type of online_text_entry
            let url: URL? // Requires submission_type of online_url or basic_lti_launch
            let file_ids: [String]? // Requires submission_type of online_upload
            let media_comment_id: String? // Requires submission_type of media_recording
            let media_comment_type: MediaCommentType? // Requires submission_type of media_recording
        }

        let submission: Submission
    }

    let context: Context
    let assignmentID: String

    public let body: Body?
    public let method = APIMethod.post
    public var path: String {
        return "\(context.pathComponent)/assignments/\(assignmentID)/submissions"
    }
}

// https://canvas.instructure.com/doc/api/submissions.html#method.submissions_api.update
struct PutSubmissionGradeRequest: APIRequestable {
    typealias Response = APISubmission
    struct Body: Codable, Equatable {
        struct Submission: Codable, Equatable {
            let posted_grade: String?
        }

        let submission: Submission
    }

    let courseID: String
    let assignmentID: String
    let userID: String

    let body: Body?
    let method = APIMethod.put
    var path: String {
        let context = ContextModel(.course, id: courseID)
        return "\(context.pathComponent)/assignments/\(assignmentID)/submissions/\(userID)"
    }
}
