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

extension APIEnrollment {
    public static func make(
        id: String? = nil,
        course_id: String? = nil,
        course_section_id: String? = nil,
        enrollment_state: EnrollmentState = .active,
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
        current_period_computed_final_grade: String? = nil
    ) -> APIEnrollment {
        return APIEnrollment(
            id: id,
            course_id: course_id,
            course_section_id: course_section_id,
            enrollment_state: enrollment_state,
            user_id: user_id,
            associated_user_id: associated_user_id,
            role: role,
            role_id: role_id,
            start_at: start_at,
            end_at: end_at,
            grades: grades,
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
            current_period_computed_final_grade: current_period_computed_final_grade
        )
    }
}
