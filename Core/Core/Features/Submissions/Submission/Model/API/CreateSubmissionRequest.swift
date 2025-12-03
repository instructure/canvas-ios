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

// https://canvas.instructure.com/doc/api/submissions.html#method.submissions.create
public struct CreateSubmissionRequest: APIRequestable, Equatable {
    public typealias Response = APISubmission
    public struct Body: Codable, Equatable {
        public struct Submission: Codable, Equatable {
            let annotatable_attachment_id: String? // Required if submission_type is student_annotation
            fileprivate(set) var comment: String?
            let group_comment: Bool?
            let submission_type: SubmissionType
            let body: String? // Requires submission_type of online_text_entry
            let url: URL? // Requires submission_type of online_url or basic_lti_launch
            let file_ids: [String]? // Requires submission_type of online_upload
            let media_comment_id: String? // Requires submission_type of media_recording
            let media_comment_type: MediaCommentType? // Requires submission_type of media_recording

            public init(
                annotatable_attachment_id: String? = nil,
                text_comment: String? = nil,
                group_comment: Bool?,
                submission_type: SubmissionType,
                body: String? = nil,
                url: URL? = nil,
                file_ids: [String]? = nil,
                media_comment_id: String? = nil,
                media_comment_type: MediaCommentType? = nil
            ) {
                self.annotatable_attachment_id = annotatable_attachment_id
                self.comment = text_comment
                self.group_comment = group_comment ?? false
                self.submission_type = submission_type
                self.body = body
                self.url = url
                self.file_ids = file_ids
                self.media_comment_id = media_comment_id
                self.media_comment_type = media_comment_type
            }
        }

        struct Comment: Codable, Equatable {
            let text_comment: String
        }

        public init(submission: Submission) {
            self.submission = submission

            // For individually graded submissions, comment needs to be set as comment[text_comment].
            // For group graded submissions, comment needs to be set as submission[comment].
            if submission.group_comment == false {
                self.comment = submission.comment.flatMap(Comment.init(text_comment:))
                self.submission.comment = nil
            } else {
                self.comment = nil
            }
        }

        private(set) var submission: Submission
        let comment: Comment?
    }

    let context: Context
    let assignmentID: String

    public let body: Body?
    public var method: APIMethod { .post }
    public var path: String {
        return "\(context.pathComponent)/assignments/\(assignmentID)/submissions"
    }

    public init(context: Context, assignmentID: String, body: Body?) {
        self.context = context
        self.assignmentID = assignmentID
        self.body = body
    }
}
