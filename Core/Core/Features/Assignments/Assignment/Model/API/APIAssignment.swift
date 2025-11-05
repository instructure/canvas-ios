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

// https://canvas.instructure.com/doc/api/assignments.html#Assignment
public struct APIAssignment: Codable, Equatable {
    let allowed_attempts: Int?
    let allowed_extensions: [String]?
    let all_dates: [APIAssignmentDate]?
    let annotatable_attachment_id: String?
    let anonymize_students: Bool?
    let anonymous_submissions: Bool?
    let assignment_group_id: ID?
    let can_submit: Bool?
    let course_id: ID
    let course: APICourse?
    let description: String?
    let discussion_topic: APIDiscussionTopic?
    let due_at: Date?
    let external_tool_tag_attributes: APIExternalToolTagAttributes?
    let grade_group_students_individually: Bool?
    let grading_standard_id: ID?
    let grading_type: GradingType
    let group_category_id: ID?
    let has_submitted_submissions: Bool?
    let has_overrides: Bool?
    var html_url: URL
    let id: ID
    let in_closed_grading_period: Bool?
    let is_quiz_lti_assignment: Bool?
    let locked_for_user: Bool? // This also returns true if the assignment is locked by date, so there's no need to manually check the `lock_at` and `unlock_at` parameters.
    let lock_at: Date?
    let lock_explanation: String?
    let moderated_grading: Bool?
    let name: String
    let needs_grading_count: Int?
    let only_visible_to_overrides: Bool?
    let overrides: [APIAssignmentOverride]?
    let planner_override: APIPlannerOverride?
    let points_possible: Double?
    let position: Int?
    let published: Bool?
    let quiz_id: ID?
    var rubric: [APIRubricCriterion]?
    var rubric_settings: APIRubricSettings?
    let score_statistics: APIScoreStatistics?
    var submission: APIList<APISubmission>?
    let submission_types: [SubmissionType]
    let unlock_at: Date?
    let unpublishable: Bool?
    let url: URL?
    let use_rubric_for_grading: Bool?
    let hide_in_gradebook: Bool?

    // Checkpoints
    let has_sub_assignments: Bool? // include[]=checkpoints
    let checkpoints: [APIAssignmentCheckpoint]? // include[]=checkpoints
}

extension APIAssignment {
    // https://canvas.instructure.com/doc/api/assignments.html#ExternalToolTagAttributes
    public struct APIExternalToolTagAttributes: Codable, Equatable {
        let content_id: ID? // undocumented
    }

    public struct APIScoreStatistics: Codable, Equatable {
        let mean: Double
        let min: Double
        let max: Double
    }
}

#if DEBUG
extension APIAssignment {
    public static func make(
        allowed_attempts: Int? = -1,
        allowed_extensions: [String]? = nil,
        all_dates: [APIAssignmentDate]? = nil,
        annotatable_attachment_id: String? = nil,
        anonymize_students: Bool? = nil,
        anonymous_submissions: Bool? = nil,
        assignment_group_id: ID? = nil,
        can_submit: Bool? = true,
        course_id: ID = "1",
        course: APICourse? = nil,
        description: String? = "<p>Do the following:</p>...",
        discussion_topic: APIDiscussionTopic? = nil,
        due_at: Date? = nil,
        external_tool_tag_attributes: APIExternalToolTagAttributes? = nil,
        grade_group_students_individually: Bool? = nil,
        grading_standard_id: ID? = nil,
        grading_type: GradingType = .points,
        group_category_id: String? = nil,
        has_submitted_submissions: Bool? = false,
        has_overrides: Bool? = false,
        html_url: URL? = nil,
        id: ID = "1",
        in_closed_grading_period: Bool? = false,
        is_quiz_lti_assignment: Bool? = false,
        locked_for_user: Bool? = false,
        lock_at: Date? = nil,
        lock_explanation: String? = nil,
        moderated_grading: Bool? = nil,
        name: String = "some assignment",
        needs_grading_count: Int = 1,
        only_visible_to_overrides: Bool? = false,
        overrides: [APIAssignmentOverride]? = nil,
        planner_override: APIPlannerOverride? = nil,
        points_possible: Double? = 10,
        position: Int? = 0,
        published: Bool? = true,
        quiz_id: ID? = nil,
        rubric: [APIRubricCriterion]? = nil,
        rubric_settings: APIRubricSettings? = .make(),
        score_statistics: APIScoreStatistics? = nil,
        submission: APISubmission? = .make(submitted_at: nil, workflow_state: .unsubmitted),
        submissions: [APISubmission]? = nil,
        submission_types: [SubmissionType] = [.online_text_entry],
        unlock_at: Date? = nil,
        unpublishable: Bool? = true,
        url: URL? = nil,
        use_rubric_for_grading: Bool? = nil,
        hide_in_gradebook: Bool? = false,
        has_sub_assignments: Bool? = nil,
        checkpoints: [APIAssignmentCheckpoint]? = nil
    ) -> APIAssignment {

        var submissionList: APIList<APISubmission>?
        if let submissions = submissions, submissions.count > 0 {
            submissionList = APIList<APISubmission>(values: submissions)
        } else if let submission = submission {
            submissionList = APIList<APISubmission>( submission )
        }

        return APIAssignment(
            allowed_attempts: allowed_attempts,
            allowed_extensions: allowed_extensions,
            all_dates: all_dates,
            annotatable_attachment_id: annotatable_attachment_id,
            anonymize_students: anonymize_students,
            anonymous_submissions: anonymous_submissions,
            assignment_group_id: assignment_group_id,
            can_submit: can_submit,
            course_id: course_id,
            course: course,
            description: description,
            discussion_topic: discussion_topic,
            due_at: due_at,
            external_tool_tag_attributes: external_tool_tag_attributes,
            grade_group_students_individually: grade_group_students_individually,
            grading_standard_id: grading_standard_id,
            grading_type: grading_type,
            group_category_id: ID(group_category_id),
            has_submitted_submissions: has_submitted_submissions,
            has_overrides: has_overrides,
            html_url: html_url ?? URL(string: "/courses/\(course_id)/assignments/\(id)")!,
            id: id,
            in_closed_grading_period: in_closed_grading_period,
            is_quiz_lti_assignment: is_quiz_lti_assignment,
            locked_for_user: locked_for_user,
            lock_at: lock_at,
            lock_explanation: lock_explanation,
            moderated_grading: moderated_grading,
            name: name,
            needs_grading_count: needs_grading_count,
            only_visible_to_overrides: only_visible_to_overrides,
            overrides: overrides,
            planner_override: planner_override,
            points_possible: points_possible,
            position: position,
            published: published,
            quiz_id: quiz_id,
            rubric: rubric,
            rubric_settings: rubric_settings,
            score_statistics: score_statistics,
            submission: submissionList,
            submission_types: submission_types,
            unlock_at: unlock_at,
            unpublishable: unpublishable,
            url: url,
            use_rubric_for_grading: use_rubric_for_grading,
            hide_in_gradebook: hide_in_gradebook,
            has_sub_assignments: has_sub_assignments,
            checkpoints: checkpoints
        )
    }
}

#endif
