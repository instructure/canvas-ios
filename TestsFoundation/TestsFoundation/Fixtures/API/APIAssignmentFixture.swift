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
@testable import Core

extension APIAssignment {
    public static func make(
        id: ID = "1",
        course_id: ID = "1",
        quiz_id: ID? = nil,
        name: String = "some assignment",
        description: String? = "<p>Do the following:</p>...",
        points_possible: Double? = 10,
        due_at: Date? = nil,
        html_url: URL? = nil,
        submission: APISubmission? = .make(submitted_at: nil, workflow_state: .unsubmitted),
        submissions: [APISubmission]? = nil,
        grade_group_students_individually: Bool? = nil,
        grading_type: GradingType = .points,
        submission_types: [SubmissionType] = [.online_text_entry],
        allowed_extensions: [String]? = nil,
        position: Int = 0,
        unlock_at: Date? = nil,
        lock_at: Date? = nil,
        locked_for_user: Bool? = false,
        lock_explanation: String? = nil,
        url: URL? = nil,
        discussion_topic: APIDiscussionTopic? = nil,
        rubric: [APIRubric]? = nil,
        use_rubric_for_grading: Bool? = nil,
        rubric_settings: APIRubricSettings? = nil,
        assignment_group_id: ID? = nil
    ) -> APIAssignment {

        var submissionList: APIList<APISubmission>?
        if let submissions = submissions, submissions.count > 0 {
            submissionList = APIList<APISubmission>(values: submissions)
        } else if let submission = submission {
            submissionList = APIList<APISubmission>( submission )
        }

        return APIAssignment(
            id: id,
            course_id: course_id,
            quiz_id: quiz_id,
            name: name,
            description: description,
            points_possible: points_possible,
            due_at: due_at,
            html_url: html_url ?? URL(string: "https://canvas.instructure.com/courses/\(course_id)/assignments/\(id)")!,
            grade_group_students_individually: grade_group_students_individually,
            grading_type: grading_type,
            submission_types: submission_types,
            allowed_extensions: allowed_extensions,
            position: position,
            unlock_at: unlock_at,
            lock_at: lock_at,
            locked_for_user: locked_for_user,
            lock_explanation: lock_explanation,
            url: url,
            discussion_topic: discussion_topic,
            rubric: rubric,
            submission: submissionList,
            use_rubric_for_grading: use_rubric_for_grading,
            rubric_settings: rubric_settings,
            assignment_group_id: assignment_group_id
        )
    }
}

extension APIAssignmentNoSubmission {
    public static func make(
        id: ID = "1",
        course_id: ID = "1",
        quiz_id: ID? = nil,
        name: String = "some assignment",
        description: String? = "<p>Do the following:</p>...",
        points_possible: Double? = 10,
        due_at: Date? = nil,
        html_url: URL = URL(string: "https://canvas.instructure.com/courses/1/assignments/1")!,
        grade_group_students_individually: Bool? = nil,
        grading_type: GradingType = .points,
        submission_types: [SubmissionType] = [.online_text_entry],
        allowed_extensions: [String]? = nil,
        position: Int = 0,
        unlock_at: Date? = nil,
        lock_at: Date? = nil,
        locked_for_user: Bool? = false,
        url: URL? = nil,
        discussion_topic: APIDiscussionTopic? = nil,
        rubric: [APIRubric]? = nil,
        use_rubric_for_grading: Bool? = nil,
        assignment_group_id: ID? = nil
    ) -> APIAssignmentNoSubmission {
        return APIAssignmentNoSubmission(
            id: id,
            course_id: course_id,
            quiz_id: quiz_id,
            name: name,
            description: description,
            points_possible: points_possible,
            due_at: due_at,
            html_url: html_url,
            grade_group_students_individually: grade_group_students_individually,
            grading_type: grading_type,
            submission_types: submission_types,
            allowed_extensions: allowed_extensions,
            position: position,
            unlock_at: unlock_at,
            lock_at: lock_at,
            locked_for_user: locked_for_user,
            url: url,
            discussion_topic: discussion_topic,
            rubric: rubric,
            use_rubric_for_grading: use_rubric_for_grading,
            assignment_group_id: assignment_group_id
        )
    }
}
