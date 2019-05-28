//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
@testable import Core

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
        late_policy_status: LatePolicyStatus? = nil,
        points_deducted: Double? = nil,
        submission_comments: [APISubmissionComment]? = nil,
        submission_history: [APISubmission]? = nil,
        user: APISubmissionUser? = nil,
        rubric_assessment: APIRubricAssessmentMap? = nil
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
            late_policy_status: late_policy_status,
            points_deducted: points_deducted,
            submission_comments: submission_comments,
            submission_history: submission_history,
            user: user,
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
        html_url: URL = URL(string: "/users/1")!
    ) -> APISubmissionCommentAuthor {
        return APISubmissionCommentAuthor(
            id: id,
            display_name: display_name,
            avatar_image_url: avatar_image_url,
            html_url: html_url
        )
    }
}

extension APISubmissionUser {
    public static func make(
        id: String = "1",
        name: String? = "Bob",
        short_name: String = "Bob",
        avatar_url: URL? = nil
    ) -> APISubmissionUser {
        return APISubmissionUser(
            id: id,
            name: name,
            short_name: short_name,
            avatar_url: avatar_url
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
