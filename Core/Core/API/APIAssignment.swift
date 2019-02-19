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
    let quiz_id: ID?
    let name: String
    let description: String?
    let points_possible: Double?
    let due_at: Date?
    let html_url: URL
    let submission: APISubmission?
    let grading_type: GradingType
    let submission_types: [SubmissionType]
    let allowed_extensions: [String]?
    let position: Int
    let unlock_at: Date?
    let lock_at: Date?
    let locked_for_user: Bool?
    let url: URL?
}
