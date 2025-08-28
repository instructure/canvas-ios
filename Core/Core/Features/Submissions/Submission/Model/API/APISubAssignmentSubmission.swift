//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

public struct APISubAssignmentSubmission: Codable, Equatable {
    let user_id: ID
    let sub_assignment_tag: String

    // Status
    let excused: Bool?
    let late: Bool?
    let late_policy_status: LatePolicyStatus?
    let seconds_late: Int?
    let missing: Bool?
    let custom_grade_status_id: String?

    // Score
    let entered_score: Double?
    let score: Double?
    let published_score: Double?

    // Grade
    let entered_grade: String?
    let grade: String?
    let published_grade: String?
    let grade_matches_current_submission: Bool?
}

#if DEBUG

extension APISubAssignmentSubmission {
    public static func make(
        user_id: String = "",
        sub_assignment_tag: String = "",
        excused: Bool? = nil,
        late: Bool? = nil,
        late_policy_status: LatePolicyStatus? = nil,
        seconds_late: Int? = nil,
        missing: Bool? = nil,
        custom_grade_status_id: String? = nil,
        entered_score: Double? = nil,
        score: Double? = nil,
        published_score: Double? = nil,
        entered_grade: String? = nil,
        grade: String? = nil,
        published_grade: String? = nil,
        grade_matches_current_submission: Bool? = nil
    ) -> APISubAssignmentSubmission {
        return APISubAssignmentSubmission(
            user_id: ID(user_id),
            sub_assignment_tag: sub_assignment_tag,
            excused: excused,
            late: late,
            late_policy_status: late_policy_status,
            seconds_late: seconds_late,
            missing: missing,
            custom_grade_status_id: custom_grade_status_id,
            entered_score: entered_score,
            score: score,
            published_score: published_score,
            entered_grade: entered_grade,
            grade: grade,
            published_grade: published_grade,
            grade_matches_current_submission: grade_matches_current_submission
        )
    }
}

#endif
