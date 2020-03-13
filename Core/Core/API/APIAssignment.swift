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
    let id: ID
    let course_id: ID
    let quiz_id: ID?
    let name: String
    let description: String?
    let points_possible: Double?
    let due_at: Date?
    let html_url: URL
    let grade_group_students_individually: Bool?
    let grading_type: GradingType
    let submission_types: [SubmissionType]
    let allowed_extensions: [String]?
    let position: Int
    let unlock_at: Date?
    let lock_at: Date?
    let locked_for_user: Bool?
    let lock_explanation: String?
    let url: URL?
    let discussion_topic: APIDiscussionTopic?
    let rubric: [APIRubric]?
    var submission: APIList<APISubmission>?
    let use_rubric_for_grading: Bool?
    let rubric_settings: APIRubricSettings?
    let assignment_group_id: ID?
}

public struct APIAssignmentNoSubmission: Codable, Equatable {
    let id: ID
    let course_id: ID
    let quiz_id: ID?
    let name: String
    let description: String?
    let points_possible: Double?
    let due_at: Date?
    let html_url: URL
    let grade_group_students_individually: Bool?
    let grading_type: GradingType
    let submission_types: [SubmissionType]
    let allowed_extensions: [String]?
    let position: Int
    let unlock_at: Date?
    let lock_at: Date?
    let locked_for_user: Bool?
    let url: URL?
    let discussion_topic: APIDiscussionTopic?
    let rubric: [APIRubric]?
    let use_rubric_for_grading: Bool?
    let assignment_group_id: ID?

    func toAPIAssignment() -> APIAssignment {
        return APIAssignment(
            id: id, course_id: course_id, quiz_id: quiz_id, name: name,
            description: description, points_possible: points_possible,
            due_at: due_at, html_url: html_url,
            grade_group_students_individually: grade_group_students_individually,
            grading_type: grading_type, submission_types: submission_types,
            allowed_extensions: allowed_extensions, position: position,
            unlock_at: unlock_at, lock_at: lock_at, locked_for_user: locked_for_user, lock_explanation: nil,
            url: url, discussion_topic: discussion_topic, rubric: rubric, submission: nil,
            use_rubric_for_grading: use_rubric_for_grading, rubric_settings: nil, assignment_group_id: assignment_group_id)
    }
}
