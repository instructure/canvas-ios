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

extension APIEnrollment {
    public static func make(
        id: ID? = "1",
        course_id: String? = nil,
        course_section_id: String? = nil,
        enrollment_state: EnrollmentState = .active,
        type: String = "StudentEnrollment",
        user_id: String = "12",
        associated_user_id: String? = nil,
        role: String = "StudentEnrollment",
        role_id: String = "3",
        start_at: Date? = nil,
        end_at: Date? = nil,
        grades: Grades? = nil,
        computed_current_score: Double? = nil,
        computed_final_score: Double? = nil,
        computed_current_grade: String? = nil,
        computed_final_grade: String? = nil,
        multiple_grading_periods_enabled: Bool? = false,
        totals_for_all_grading_periods_option: Bool? = true,
        current_grading_period_id: String? = "1",
        current_period_computed_current_score: Double? = nil,
        current_period_computed_final_score: Double? = nil,
        current_period_computed_current_grade: String? = nil,
        current_period_computed_final_grade: String? = nil,
        user: APIUser? = .make(),
        observed_user: APIUser? = nil
    ) -> APIEnrollment {
        return APIEnrollment(
            id: id,
            course_id: course_id,
            course_section_id: course_section_id,
            enrollment_state: enrollment_state,
            type: type,
            user_id: user_id,
            associated_user_id: associated_user_id,
            role: role,
            role_id: role_id,
            start_at: start_at,
            end_at: end_at,
            grades: grades,
            user: user,
            computed_current_score: computed_current_score,
            computed_final_score: computed_final_score,
            computed_current_grade: computed_current_grade,
            computed_final_grade: computed_final_grade,
            multiple_grading_periods_enabled: multiple_grading_periods_enabled,
            totals_for_all_grading_periods_option: totals_for_all_grading_periods_option,
            current_grading_period_id: current_grading_period_id,
            current_period_computed_current_score: current_period_computed_current_score,
            current_period_computed_final_score: current_period_computed_final_score,
            current_period_computed_current_grade: current_period_computed_current_grade,
            current_period_computed_final_grade: current_period_computed_final_grade,
            observed_user: observed_user
        )
    }
}

extension APIEnrollment.Grades {
    public static func make(
        html_url: String = "/grades",
        current_grade: String? = nil,
        final_grade: String? = nil,
        current_score: Double? = nil,
        final_score: Double? = nil
    ) -> Self {
        return Self(
            html_url: html_url,
            current_grade: current_grade,
            final_grade: final_grade,
            current_score: current_score,
            final_score: final_score
        )
    }
}
