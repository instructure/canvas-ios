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

// https://canvas.instructure.com/doc/api/submissions.html#Submission
public struct APISubmission: Codable, Equatable {
    let id: ID
    let assignment_id: ID
    let user_id: ID
    let body: String?
    var grade: String?
    var score: Double?
    let submission_type: SubmissionType?
    let submitted_at: Date?
    let late: Bool
    let excused: Bool?
    let missing: Bool
    let workflow_state: SubmissionWorkflowState
    let attempt: Int?
    let attachments: [APIFile]?
    let discussion_entries: [APIDiscussionEntry]?
    let preview_url: URL?
    let url: URL?
    let media_comment: APIMediaComment?
    var graded_at: Date?
    let grade_matches_current_submission: Bool
    let external_tool_url: APIURL?

    // late policies
    let late_policy_status: LatePolicyStatus?
    let points_deducted: Double?

    var submission_comments: [APISubmissionComment]? // include[]=submission_comments
    let submission_history: [APISubmission]? // include[]=submission_history
    var user: APISubmissionUser? // include[]=user
    let assignment: APIAssignment? // include[]=assignment
    var rubric_assessment: APIRubricAssessmentMap?  // include[]=rubric_assessment
}

public struct APISubmissionUser: Codable, Equatable {
    let id: String
    let name: String?
    let short_name: String
    let avatar_url: URL?
    let pronouns: String?
}

// https://canvas.instructure.com/doc/api/submissions.html#SubmissionComment
public struct APISubmissionComment: Codable, Equatable {
    let id: String
    let author_id: String
    let author_name: String
    let author: APISubmissionCommentAuthor
    let comment: String
    let created_at: Date
    let edited_at: Date?
    let media_comment: APISubmissionCommentMedia?
    let attachments: [APIFile]?
}

public struct APISubmissionCommentAuthor: Codable, Equatable {
    let id: String
    let display_name: String
    let avatar_image_url: URL?
    let html_url: URL
    let pronouns: String?
}

public struct APISubmissionCommentMedia: Codable, Equatable {
    let url: URL
    let media_id: String
    let media_type: MediaCommentType
    let display_name: String?
}

public struct APISubmissionSummary: Codable, Equatable {
    let graded: Int
    let ungraded: Int
    let not_submitted: Int
}

#if DEBUG
extension APISubmission {
    public static func make(
        id: ID = "1",
        assignment_id: ID = "1",
        user_id: ID = "1",
        body: String? = nil,
        grade: String? = nil,
        score: Double? = nil,
        submission_type: SubmissionType? = nil,
        submitted_at: Date? = Date(fromISOString: "2019-03-13T21:00:00Z"),
        late: Bool = false,
        excused: Bool? = false,
        missing: Bool = false,
        workflow_state: SubmissionWorkflowState = .submitted,
        attempt: Int? = nil,
        attachments: [APIFile]? = nil,
        discussion_entries: [APIDiscussionEntry]? = nil,
        preview_url: URL? = nil,
        url: URL? = nil,
        media_comment: APIMediaComment? = nil,
        graded_at: Date? = nil,
        grade_matches_current_submission: Bool = true,
        late_policy_status: LatePolicyStatus? = nil,
        points_deducted: Double? = nil,
        submission_comments: [APISubmissionComment]? = nil,
        submission_history: [APISubmission]? = nil,
        user: APISubmissionUser? = nil,
        assignment: APIAssignment? = nil,
        rubric_assessment: APIRubricAssessmentMap? = nil,
        external_tool_url: APIURL? = nil
    ) -> APISubmission {
        return APISubmission(
            id: id,
            assignment_id: assignment_id,
            user_id: user_id,
            body: body,
            grade: grade,
            score: score,
            submission_type: submission_type,
            submitted_at: submitted_at,
            late: late,
            excused: excused,
            missing: missing,
            workflow_state: workflow_state,
            attempt: attempt,
            attachments: attachments,
            discussion_entries: discussion_entries,
            preview_url: preview_url,
            url: url,
            media_comment: media_comment,
            graded_at: graded_at,
            grade_matches_current_submission: grade_matches_current_submission,
            external_tool_url: external_tool_url,
            late_policy_status: late_policy_status,
            points_deducted: points_deducted,
            submission_comments: submission_comments,
            submission_history: submission_history,
            user: user,
            assignment: assignment,
            rubric_assessment: rubric_assessment
        )
    }
}

extension APISubmissionComment {
    public static func make(
        id: String = "1",
        author_id: String = "1",
        author_name: String = "Steve",
        author: APISubmissionCommentAuthor = .make(),
        comment: String = "comment",
        created_at: Date = Date(fromISOString: "2019-03-13T21:00:36Z")!,
        edited_at: Date? = nil,
        media_comment: APISubmissionCommentMedia? = nil,
        attachments: [APIFile]? = nil
    ) -> APISubmissionComment {
        return APISubmissionComment(
            id: id,
            author_id: author_id,
            author_name: author_name,
            author: author,
            comment: comment,
            created_at: created_at,
            edited_at: edited_at,
            media_comment: media_comment,
            attachments: attachments
        )
    }
}

extension APISubmissionCommentAuthor {
    public static func make(
        id: String = "1",
        display_name: String = "Steve",
        avatar_image_url: URL? = nil,
        html_url: URL = URL(string: "/users/1")!,
        pronouns: String? = nil
    ) -> APISubmissionCommentAuthor {
        return APISubmissionCommentAuthor(
            id: id,
            display_name: display_name,
            avatar_image_url: avatar_image_url,
            html_url: html_url,
            pronouns: pronouns
        )
    }

    public static func make(from user: APIUser) -> APISubmissionCommentAuthor {
        APISubmissionCommentAuthor(
            id: user.id.value,
            display_name: user.name,
            avatar_image_url: user.avatar_url?.rawValue,
            html_url: URL(string: "/users/\(user.id)")!,
            pronouns: user.pronouns
        )
    }
}

extension APISubmissionUser {
    public static func make(
        id: String = "1",
        name: String? = "Bob",
        short_name: String = "Bob",
        avatar_url: URL? = nil,
        pronouns: String? = nil
    ) -> APISubmissionUser {
        return APISubmissionUser(
            id: id,
            name: name,
            short_name: short_name,
            avatar_url: avatar_url,
            pronouns: pronouns
        )
    }

    public static func make(from user: APIUser) -> APISubmissionUser {
        APISubmissionUser(
            id: user.id.value,
            name: user.name,
            short_name: user.short_name,
            avatar_url: user.avatar_url?.rawValue,
            pronouns: user.pronouns
        )
    }
}

extension APISubmissionCommentMedia {
    public static func make(
        url: URL = URL(string: "data:video/x-m4v,")!,
        media_id: String = "m1",
        media_type: MediaCommentType = .video,
        display_name: String? = nil
    ) -> APISubmissionCommentMedia {
        return APISubmissionCommentMedia(
            url: url,
            media_id: media_id,
            media_type: media_type,
            display_name: display_name
        )
    }
}

extension APISubmissionSummary {
    public static func make(
        graded: Int = 1,
        ungraded: Int = 2,
        not_submitted: Int = 3
    ) -> APISubmissionSummary {
        APISubmissionSummary(
            graded: graded,
            ungraded: ungraded,
            not_submitted: not_submitted
        )
    }
}
#endif

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

    init(courseID: String, assignmentID: String, userID: String, body: Body? = nil) {
        self.courseID = courseID
        self.assignmentID = assignmentID
        self.userID = userID
        self.body = body
    }

    let body: Body?
    let method = APIMethod.put
    var path: String {
        let context = Context(.course, id: courseID)
        return "\(context.pathComponent)/assignments/\(assignmentID)/submissions/\(userID)"
    }
}

public struct GetRecentlyGradedSubmissionsRequest: APIRequestable {
    public typealias Response = [APISubmission]

    let userID: String

    public var path: String {
        let context = Context(.user, id: userID)
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
