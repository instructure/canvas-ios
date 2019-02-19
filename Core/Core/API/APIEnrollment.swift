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

// https://canvas.instructure.com/doc/api/enrollments.html#Enrollment
struct APIEnrollment: Codable, Equatable {
    let id: String?
    let course_id: String?
    // let sis_course_id: String?
    // let course_integration_id: String?
    let course_section_id: String?
    // let section_integration_id: String?
    // let sis_account_id: String?
    // let sis_section_id: String?
    // let sis_user_id: String?
    let enrollment_state: EnrollmentState
    // let limit_privileges_to_course_section: Bool?
    // let sis_import_id: String?
    // let root_account_id: String
    // let type: String
    let user_id: String
    let associated_user_id: String?
    let role: String
    let role_id: String
    // let created_at: Date
    // let updated_at: Date
    let start_at: Date?
    let end_at: Date?
    // let last_activity_at: Date?
    // let last_attended_at: Date?
    // let total_activity_time: TimeInterval
    // let html_url: String
    let grades: Grades?
    // let user: APIUser
    // let computed_current_score: Double?
    // let computed_final_score: Double?
    let computed_current_grade: String?
    // let computed_final_grade: String?
    // let unposted_current_grade: String?
    // let unposted_final_grade: String?
    // let unposted_current_score: String?
    // let unposted_final_score: String?
    // let has_grading_periods: Bool?
    // let totals_for_all_grading_periods_option: Bool?
    // let current_grading_period_title: String?
    let current_grading_period_id: String?
    let current_period_computed_current_score: Double?
    let current_period_computed_final_score: Double?
    let current_period_computed_current_grade: String?
    let current_period_computed_final_grade: String?
    // let current_period_unposted_current_score: Double?
    // let current_period_unposted_final_score: Double?
    // let current_period_unposted_current_grade: String?
    // let current_period_unposted_final_grade: String?

    // https://canvas.instructure.com/doc/api/enrollments.html#Grade
    struct Grades: Codable, Equatable {
        let html_url: String
        let current_grade: String?
        let final_grade: String?
        let current_score: Double?
        let final_score: Double?
        // let unposted_current_grade: String?
        // let unposted_final_grade: String?
        // let unposted_current_score: Double?
        // let unposted_final_score: Double?
    }
}
