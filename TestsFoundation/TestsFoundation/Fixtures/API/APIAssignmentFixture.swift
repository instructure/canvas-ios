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
        html_url: URL = URL(string: "https://canvas.instructure.com/courses/1/assignments/1")!,
        submission: APISubmission? = .make(workflow_state: .unsubmitted),
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
        use_rubric_for_grading: Bool? = nil
    ) -> APIAssignment {
        return APIAssignment(
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
            lock_explanation: lock_explanation,
            url: url,
            discussion_topic: discussion_topic,
            rubric: rubric,
            submission: submission.flatMap { APIList($0) },
            use_rubric_for_grading: use_rubric_for_grading
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
        use_rubric_for_grading: Bool? = nil
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
            use_rubric_for_grading: use_rubric_for_grading
        )
    }
}
