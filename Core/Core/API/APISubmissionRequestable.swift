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
        return [ .array("include", [ "submission_comments", "submission_history", "user", "rubric_assessment"]) ]
    }
}

// https://canvas.instructure.com/doc/api/submissions.html#method.submissions_api.index
public struct GetSubmissionsRequest: APIRequestable {
    public typealias Response = [APISubmission]

    enum Include: String, CaseIterable {
        case rubric_assessment, submission_comments, submission_history, total_scores, user, group
    }

    let context: Context
    let assignmentID: String
    let grouped: Bool?
    let include: [Include]

    init(context: Context, assignmentID: String, grouped: Bool? = nil, include: [Include] = []) {
        self.context = context
        self.assignmentID = assignmentID
        self.grouped = grouped
        self.include = include
    }

    public var path: String {
        return "\(context.pathComponent)/assignments/\(assignmentID)/submissions"
    }

    public var query: [APIQueryItem] {
        var query: [APIQueryItem] = [
            .include(include.map { $0.rawValue }),
        ]
        if let grouped = grouped {
            query.append(.value("grouped", String(grouped)))
        }
        return query
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

            init(
                text_comment: String? = nil,
                submission_type: SubmissionType,
                body: String? = nil,
                url: URL? = nil,
                file_ids: [String]? = nil,
                media_comment_id: String? = nil,
                media_comment_type: MediaCommentType? = nil
            ) {
                self.text_comment = text_comment
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

        init(submission: Submission) {
            self.submission = submission
            self.comment = submission.text_comment.flatMap(Comment.init(text_comment:))
        }

        let submission: Submission
        let comment: Comment?
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
        struct Comment: Codable, Equatable {
            let group_comment: Bool
            let media_comment_id: String?
            let media_comment_type: MediaCommentType?
            let text_comment: String?
            let file_ids: [String]?

            init(text: String, forGroup: Bool = false) {
                group_comment = forGroup
                media_comment_id = nil
                media_comment_type = nil
                file_ids = nil
                text_comment = text
            }

            init(mediaID: String, type: MediaCommentType, forGroup: Bool = false) {
                group_comment = forGroup
                media_comment_id = mediaID
                media_comment_type = type
                text_comment = forGroup ? NSLocalizedString("This is a media comment", bundle: .core, comment: "") : nil
                file_ids = nil
            }

            init(fileIDs: [String], forGroup: Bool = false) {
                group_comment = forGroup
                file_ids = fileIDs
                media_comment_id = nil
                media_comment_type = nil
                text_comment = nil
            }
        }
        struct Submission: Codable, Equatable {
            let posted_grade: String?
        }

        let comment: Comment?
        let submission: Submission?
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

public struct GetRecentlyGradedSubmissionsRequest: APIRequestable {
    public typealias Response = [APISubmission]

    let userID: String

    public var path: String {
        let context = ContextModel(.user, id: userID)
        return "\(context.pathComponent)/graded_submissions"
    }

    public var query: [APIQueryItem] {
        return [
            .perPage(3),
            .include(["assignment"]),
            .bool("only_current_submissions", true),
        ]
    }
}

// https://canvas.instructure.com/doc/api/submissions.html#method.submissions_api.submission_summary
public struct GetSubmissionSummaryRequest: APIRequestable {
    public typealias Response = APISubmissionSummary

    public let context: Context
    public let assignmentID: String

    public var path: String {
        "\(context.pathComponent)/assignments/\(assignmentID)/submission_summary"
    }
}
