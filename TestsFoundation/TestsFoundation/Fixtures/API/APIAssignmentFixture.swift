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
            submission: submission,
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

extension APIAssignmentNoSubmission: Fixture {
    public static var template: Template {
        return [
            "id": "1",
            "course_id": "1",
            "name": "some assignment",
            "description": "<p>Do the following:</p>...",
            "points_possible": 10,
            "due_at": nil,
            "html_url": "https://canvas.instructure.com/courses/1/assignments/1",
            "grading_type": "points",
            "submission_types": ["online_text_entry"],
            "position": 0,
            "lockedForUser": false,
        ]
    }
}
