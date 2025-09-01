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
    let cached_due_date: Date?
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
    let group: APISubmission.Group?
    let id: ID
    let late: Bool?
    let late_policy_status: LatePolicyStatus?
    let media_comment: APIMediaComment?
    let missing: Bool?
    let points_deducted: Double?
    let posted_at: Date?
    let preview_url: URL?
    var rubric_assessment: APIRubricAssessmentMap?  // include[]=rubric_assessment
    let seconds_late: Int?
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

    // Sub-assignment (aka: Checkpoint) submissions
    let has_sub_assignment_submissions: Bool? // include[]=sub_assignment_submissions
    let sub_assignment_submissions: [APISubAssignmentSubmission]? // include[]=sub_assignment_submissions
}

extension APISubmission {
    public struct Group: Codable, Equatable {
        let id: ID?
        let name: String?
    }
}

#if DEBUG
extension APISubmission {
    public static func make(
        assignment: APIAssignment? = nil,
        assignment_id: String = "1",
        attachments: [APIFile]? = nil,
        attempt: Int? = nil,
        body: String? = nil,
        cached_due_date: Date? = nil,
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
        group: APISubmission.Group? = nil,
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
        seconds_late: Int? = nil,
        submission_comments: [APISubmissionComment]? = nil,
        submission_history: [APISubmission]? = nil,
        submission_type: SubmissionType? = nil,
        submitted_at: Date? = Date(fromISOString: "2019-03-13T21:00:00Z"),
        turnitin_data: [String: APITurnItInData.Item]? = nil,
        url: URL? = nil,
        user: APIUser? = nil,
        user_id: String = "1",
        workflow_state: SubmissionWorkflowState = .submitted,
        has_sub_assignment_submissions: Bool? = nil,
        sub_assignment_submissions: [APISubAssignmentSubmission]? = nil
    ) -> APISubmission {
        return APISubmission(
            assignment: assignment,
            assignment_id: ID(assignment_id),
            attachments: attachments,
            attempt: attempt,
            body: body,
            cached_due_date: cached_due_date,
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
            seconds_late: seconds_late,
            score: score,
            submission_comments: submission_comments,
            submission_history: submission_history,
            submission_type: submission_type,
            submitted_at: submitted_at,
            turnitin_data: turnitin_data.flatMap { APITurnItInData(rawValue: $0) },
            url: url,
            user: user,
            user_id: ID(user_id),
            workflow_state: workflow_state,
            has_sub_assignment_submissions: has_sub_assignment_submissions,
            sub_assignment_submissions: sub_assignment_submissions
        )
    }
}

#endif
