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

// https://canvas.instructure.com/doc/api/submissions.html#method.submissions_api.update
public struct PutSubmissionGradeRequest: APIRequestable {
    public typealias Response = APISubmission
    public struct Body: Codable, Equatable {
        public struct Comment: Codable, Equatable {
            let group_comment: Bool
            let media_comment_id: String?
            let media_comment_type: MediaCommentType?
            let text_comment: String?
            let file_ids: [String]?
            let attempt: Int?

            public init(text: String, forGroup: Bool = false, attempt: Int?) {
                group_comment = forGroup
                media_comment_id = nil
                media_comment_type = nil
                file_ids = nil
                text_comment = text
                self.attempt = attempt
            }

            public init(mediaID: String, type: MediaCommentType, forGroup: Bool = false, attempt: Int?) {
                group_comment = forGroup
                media_comment_id = mediaID
                media_comment_type = type
                text_comment = forGroup ? String(localized: "This is a media comment", bundle: .core) : ""
                file_ids = nil
                self.attempt = attempt
            }

            public init(fileIDs: [String], forGroup: Bool = false, attempt: Int?) {
                group_comment = forGroup
                file_ids = fileIDs
                media_comment_id = nil
                media_comment_type = nil
                text_comment = ""
                self.attempt = attempt
            }
        }
        public struct Submission: Codable, Equatable {
            let excuse: Bool?
            let posted_grade: String?
            let seconds_late_override: Int?
            let late_policy_status: String?

            public init(excuse: Bool?, posted_grade: String?, seconds_late_override: Int?) {
                self.excuse = excuse
                self.posted_grade = posted_grade
                self.seconds_late_override = seconds_late_override

                if let seconds = seconds_late_override, seconds >= 0 {
                    self.late_policy_status = "late"
                } else {
                    self.late_policy_status = nil
                }
            }
        }

        let comment: Comment?
        let submission: Submission?
        let rubric_assessment: APIRubricAssessmentMap?

        public init(comment: Comment? = nil, submission: Submission? = nil, rubric_assessment: APIRubricAssessmentMap? = nil) {
            self.comment = comment
            self.submission = submission
            self.rubric_assessment = rubric_assessment
        }
    }

    let courseID: String
    let assignmentID: String
    let userID: String

    public init(courseID: String, assignmentID: String, userID: String, body: Body? = nil) {
        self.courseID = courseID
        self.assignmentID = assignmentID
        self.userID = userID
        self.body = body
    }

    public let body: Body?
    public var method: APIMethod { .put }
    public var path: String {
        let context = Context(.course, id: courseID)
        return "\(context.pathComponent)/assignments/\(assignmentID)/submissions/\(userID)"
    }
}
