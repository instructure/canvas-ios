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
    let assignment: APIAssignment? // include[]=assignment
    let assignment_id: ID
    let attachments: [APIFile]?
    let attempt: Int?
    let body: String?
    let custom_grade_status_id: String?
    let discussion_entries: [APIDiscussionEntry]?
    let entered_grade: String?
    let entered_score: Double?
    let excused: Bool?
    let external_tool_url: APIURL?
    var grade: String?
    var graded_at: Date?
    let grade_matches_current_submission: Bool
    let grading_period_id: ID?
    let group: APISubmissionGroup?
    let id: ID
    let late: Bool?
    let late_policy_status: LatePolicyStatus?
    let media_comment: APIMediaComment?
    let missing: Bool?
    let points_deducted: Double?
    let posted_at: Date?
    let preview_url: URL?
    var rubric_assessment: APIRubricAssessmentMap?  // include[]=rubric_assessment
    var score: Double?
    var submission_comments: [APISubmissionComment]? // include[]=submission_comments
    let submission_history: [APISubmission]? // include[]=submission_history
    let submission_type: SubmissionType?
    let submitted_at: Date?
    let turnitin_data: APITurnItInData?
    @SafeURL private(set) var url: URL?
    var user: APIUser? // include[]=user
    let user_id: ID
    let workflow_state: SubmissionWorkflowState
}

public struct APISubmissionGroup: Codable, Equatable {
    let id: ID?
    let name: String?
}

// https://canvas.instructure.com/doc/api/submissions.html#SubmissionComment
public struct APISubmissionComment: Codable, Equatable {
    let id: String
    let attempt: Int?
    let author_id: ID?
    let author_name: String
    let author: APISubmissionCommentAuthor
    let comment: String
    let created_at: Date
    let edited_at: Date?
    let media_comment: APISubmissionCommentMedia?
    let attachments: [APIFile]?
}

public struct APISubmissionCommentAuthor: Codable, Equatable {
    let id: ID?
    let display_name: String?
    let avatar_image_url: APIURL?
    let html_url: URL?
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

public struct APITurnItInData: Codable, Equatable {
    let rawValue: [String: APITurnItIn]

    struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        var intValue: Int?
        init?(intValue: Int) {
            return nil
        }
    }

    init(rawValue: [String: APITurnItIn]) {
        self.rawValue = rawValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        var data: [String: APITurnItIn] = [:]
        for key in container.allKeys {
            if let codingKey = DynamicCodingKeys(stringValue: key.stringValue), let turnItIn = try? container.decode(APITurnItIn.self, forKey: codingKey) {
                data[key.stringValue] = turnItIn
            }
        }
        self.rawValue = data
    }
}

public struct APITurnItIn: Codable, Equatable {
    let status: String
    let similarity_score: Double?
    let outcome_response: APITurnItInOutcome?
}

public struct APITurnItInOutcome: Codable, Equatable {
    let outcomes_tool_placement_url: APIURL?
}

#if DEBUG
extension APISubmission {
    public static func make(
        assignment: APIAssignment? = nil,
        assignment_id: String = "1",
        attachments: [APIFile]? = nil,
        attempt: Int? = nil,
        body: String? = nil,
        custom_grade_status_id: String? = nil,
        discussion_entries: [APIDiscussionEntry]? = nil,
        entered_grade: String? = nil,
        entered_score: Double? = nil,
        excused: Bool? = false,
        external_tool_url: APIURL? = nil,
        grade: String? = nil,
        graded_at: Date? = nil,
        grade_matches_current_submission: Bool = true,
        grading_period_id: String? = nil,
        group: APISubmissionGroup? = nil,
        id: String = "1",
        late: Bool = false,
        late_policy_status: LatePolicyStatus? = nil,
        media_comment: APIMediaComment? = nil,
        missing: Bool? = false,
        points_deducted: Double? = nil,
        posted_at: Date? = nil,
        preview_url: URL? = nil,
        rubric_assessment: APIRubricAssessmentMap? = nil,
        score: Double? = nil,
        submission_comments: [APISubmissionComment]? = nil,
        submission_history: [APISubmission]? = nil,
        submission_type: SubmissionType? = nil,
        submitted_at: Date? = Date(fromISOString: "2019-03-13T21:00:00Z"),
        turnitin_data: [String: APITurnItIn]? = nil,
        url: URL? = nil,
        user: APIUser? = nil,
        user_id: String = "1",
        workflow_state: SubmissionWorkflowState = .submitted
    ) -> APISubmission {
        return APISubmission(
            assignment: assignment,
            assignment_id: ID(assignment_id),
            attachments: attachments,
            attempt: attempt,
            body: body,
            custom_grade_status_id: custom_grade_status_id,
            discussion_entries: discussion_entries,
            entered_grade: entered_grade,
            entered_score: entered_score,
            excused: excused,
            external_tool_url: external_tool_url,
            grade: grade,
            graded_at: graded_at,
            grade_matches_current_submission: grade_matches_current_submission,
            grading_period_id: ID(grading_period_id),
            group: group,
            id: ID(id),
            late: late,
            late_policy_status: late_policy_status,
            media_comment: media_comment,
            missing: missing,
            points_deducted: points_deducted,
            posted_at: posted_at,
            preview_url: preview_url,
            rubric_assessment: rubric_assessment,
            score: score,
            submission_comments: submission_comments,
            submission_history: submission_history,
            submission_type: submission_type,
            submitted_at: submitted_at,
            turnitin_data: turnitin_data.flatMap { APITurnItInData(rawValue: $0) },
            url: url,
            user: user,
            user_id: ID(user_id),
            workflow_state: workflow_state
        )
    }
}

extension APISubmissionComment {
    public static func make(
        id: String = "1",
        attempt: Int? = 0,
        author_id: ID? = "1",
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
            attempt: attempt,
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
        id: ID? = "1",
        display_name: String? = "Steve",
        avatar_image_url: APIURL? = nil,
        html_url: URL? = URL(string: "/users/1"),
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
            id: user.id,
            display_name: user.name,
            avatar_image_url: user.avatar_url,
            html_url: URL(string: "/users/\(user.id)"),
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

extension APITurnItIn {
    public static func make(
        status: String = "scored",
        similarity_score: Double? = 86,
        outcome_response: APITurnItInOutcome? = .make()
    ) -> APITurnItIn {
        APITurnItIn(
            status: status,
            similarity_score: similarity_score,
            outcome_response: outcome_response
        )
    }
}

extension APITurnItInOutcome {
    public static func make(outcomes_tool_placement_url: URL? = nil) -> APITurnItInOutcome {
        APITurnItInOutcome(outcomes_tool_placement_url: APIURL(rawValue: outcomes_tool_placement_url))
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
        return [ .array("include", [ "submission_comments", "submission_history", "user", "rubric_assessment", "group"]) ]
    }
}

// https://canvas.instructure.com/doc/api/submissions.html#method.submissions_api.for_students
public struct GetSubmissionsForStudentRequest: APIRequestable {
    public typealias Response = [APISubmission]

    public let path: String
    public let query: [APIQueryItem]

    /**
     - Parameters:
        - context: Supported `ContextType`s are:
            - `course`
            - `section`
     */
    init(context: Context, studentID: String) {
        guard [.course, .section].contains(context.contextType) else { fatalError("Unsupported ContextType") }

        self.path = "\(context.pathComponent)/students/submissions"
        self.query = [
            .perPage(100),
            .array("student_ids", [studentID]),
            .include(GetSubmissionsRequest.Include.allCases.map { $0.rawValue })
        ]
    }
}

// https://canvas.instructure.com/doc/api/submissions.html#method.submissions_api.index
public struct GetSubmissionsRequest: APIRequestable {
    public typealias Response = [APISubmission]

    enum Include: String, CaseIterable {
        case rubric_assessment, submission_comments, submission_history, total_scores, user, group, assignment
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
            .perPage(100),
            .include(include.map { $0.rawValue })
        ]
        if let grouped = grouped {
            query.append(.bool("grouped", grouped))
        }
        return query
    }
}

// https://canvas.instructure.com/doc/api/submissions.html#method.submissions.create
public struct CreateSubmissionRequest: APIRequestable {
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

            public init(excuse: Bool?, posted_grade: String?) {
                self.excuse = excuse
                self.posted_grade = posted_grade
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
            .bool("only_current_submissions", true)
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
