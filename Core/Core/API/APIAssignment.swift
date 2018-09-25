//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

// https://canvas.instructure.com/doc/api/assignments.html#Assignment
public struct APIAssignment: Codable, Equatable {
    let id: ID
    let course_id: ID
    let name: String
    let description: String?
    let points_possible: Double
    let due_at: Date?
    let html_url: String
    let submission: APISubmission?
    let grading_type: GradingType
    let submission_types: [SubmissionType]

    enum GradingType: String, Codable {
        case pass_fail, percent, letter_grade, gpa_scale, points, not_graded
    }

    enum SubmissionType: String, Codable {
        case discussion_topic
        case online_quiz
        case on_paper
        case none
        case external_tool
        case online_text_entry
        case online_url
        case online_upload
        case media_recording
    }
}
