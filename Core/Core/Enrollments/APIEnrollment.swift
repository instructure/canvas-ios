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

// https://canvas.instructure.com/doc/api/enrollments.html#Enrollment
public struct APIEnrollment: Codable, Equatable {
    let id: ID?
    let course_id: ID?
    // let sis_course_id: String?
    // let course_integration_id: String?
    let course_section_id: ID?
    // let section_integration_id: String?
    // let sis_account_id: String?
    // let sis_section_id: String?
    // let sis_user_id: String?
    let enrollment_state: EnrollmentState
    // let limit_privileges_to_course_section: Bool?
    // let sis_import_id: String?
    // let root_account_id: String
    let type: String
    let user_id: ID
    let associated_user_id: ID?
    let role: String
    let role_id: String
    // let created_at: Date
    // let updated_at: Date
    let start_at: Date?
    let end_at: Date?
    let last_activity_at: Date?
    // let last_attended_at: Date?
    // let total_activity_time: TimeInterval
    // let html_url: String
    let grades: Grades?
    let user: APIUser?
    let computed_current_score: Double?
    let computed_final_score: Double?
    let computed_current_grade: String?
    let computed_current_letter_grade: String?
    let computed_final_grade: String?
    // let unposted_current_grade: String?
    // let unposted_final_grade: String?
    // let unposted_current_score: String?
    // let unposted_final_score: String?
    // let has_grading_periods: Bool?
    let multiple_grading_periods_enabled: Bool?
    let totals_for_all_grading_periods_option: Bool?
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

    public let observed_user: APIUser?

    // https://canvas.instructure.com/doc/api/enrollments.html#Grade
    public struct Grades: Codable, Equatable {
        let html_url: String
        let current_grade: String?
        let final_grade: String?
        let current_score: Double?
        let final_score: Double?
        let override_grade: String?
        let override_score: Double?
        let unposted_current_grade: String?
        let unposted_current_score: Double?
        // let unposted_final_grade: String?
        // let unposted_final_score: Double?
    }
}

public enum EnrollmentState: String, Codable, CaseIterable {
    case active, inactive, invited, completed, creation_pending, rejected, deleted
}

#if DEBUG
extension APIEnrollment {
    public static func make(
        id: String? = "1",
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
        last_activity_at: Date? = nil,
        grades: Grades? = nil,
        computed_current_score: Double? = nil,
        computed_final_score: Double? = nil,
        computed_current_grade: String? = nil,
        computed_current_letter_grade: String? = nil,
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
            id: ID(id),
            course_id: ID(course_id),
            course_section_id: ID(course_section_id),
            enrollment_state: enrollment_state,
            type: type,
            user_id: ID(user_id),
            associated_user_id: ID(associated_user_id),
            role: role,
            role_id: role_id,
            start_at: start_at,
            end_at: end_at,
            last_activity_at: last_activity_at,
            grades: grades,
            user: user,
            computed_current_score: computed_current_score,
            computed_final_score: computed_final_score,
            computed_current_grade: computed_current_grade,
            computed_current_letter_grade: computed_current_letter_grade,
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
        final_score: Double? = nil,
        override_grade: String? = nil,
        override_score: Double? = nil,
        unposted_current_grade: String? = nil,
        unposted_current_score: Double? = nil

    ) -> Self {
        return Self(
            html_url: html_url,
            current_grade: current_grade,
            final_grade: final_grade,
            current_score: current_score,
            final_score: final_score,
            override_grade: override_grade,
            override_score: override_score,
            unposted_current_grade: unposted_current_grade,
            unposted_current_score: unposted_current_score
        )
    }
}
#endif

// https://canvas.instructure.com/doc/api/enrollments.html#method.enrollments_api.create
struct PostEnrollmentRequest: APIRequestable {
    typealias Response = APIEnrollment
    struct Body: Codable, Equatable {
        struct Enrollment: Codable, Equatable {
            let user_id: String
            let type: String
            let enrollment_state: EnrollmentState
        }

        let enrollment: Enrollment
    }

    let courseID: String

    let body: Body?
    var method: APIMethod { .post }
    var path: String {
        let context = Context(.course, id: courseID)
        return "\(context.pathComponent)/enrollments"
    }
}

// https://canvas.instructure.com/doc/api/enrollments.html#method.enrollments_api.index
public struct GetEnrollmentsRequest: APIRequestable {
    public typealias Response = [APIEnrollment]
    public enum Include: String {
        case observed_users, avatar_url
    }

    public enum State: String {
        case creation_pending, active, invited, current_and_future, completed, deleted
        public static var allForParentObserver: [State] {
            return [.creation_pending, .active, .invited, .current_and_future, .completed]
        }
    }

    let context: Context
    let userID: String?
    let gradingPeriodID: String?
    let types: [String]?
    let includes: [Include]
    let states: [State]?
    let roles: [Role]?

    public init(context: Context, userID: String? = nil, gradingPeriodID: String? = nil, types: [String]? = nil, includes: [Include] = [], states: [State]? = nil, roles: [Role]? = nil) {
        self.context = context
        self.userID = userID
        self.gradingPeriodID = gradingPeriodID
        self.types = types
        self.includes = includes
        self.states = states
        self.roles = roles
    }

    public var path: String {
        return "\(context.pathComponent)/enrollments"
    }
    public var query: [APIQueryItem] {
        var query: [APIQueryItem] = [
            .value("per_page", "100"),
            .include(includes.map { $0.rawValue }),
        ]
        if let states = states {
            query.append(.array("state", states.map { $0.rawValue }))
        }
        if let roles = roles {
            query.append(.array("role", roles.map { $0.rawValue }))
        }
        if let userID = userID {
            query.append(.value("user_id", userID))
        }
        if let gradingPeriodID = gradingPeriodID {
            query.append(.value("grading_period_id", gradingPeriodID))
        }
        if let types = types {
            query.append(.array("type", types))
        }
        return query
    }
}

// https://canvas.instructure.com/doc/api/enrollments.html#method.enrollments_api.accept
// https://canvas.instructure.com/doc/api/enrollments.html#method.enrollments_api.reject
struct HandleCourseInvitationRequest: APIRequestable {
    struct Response: Codable { let success: Bool }

    let courseID: String
    let enrollmentID: String
    let isAccepted: Bool

    var method: APIMethod { .post }
    var path: String { "courses/\(courseID)/enrollments/\(enrollmentID)/\(isAccepted ? "accept" : "reject")" }
}
