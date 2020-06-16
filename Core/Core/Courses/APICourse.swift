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

// https://canvas.instructure.com/doc/api/courses.html#Course
public struct APICourse: Codable, Equatable {
    public let id: ID
    // let sis_course_id: String?
    // let uuid: String?
    // let integration_id: String?
    // let sis_import_id: String?
    let name: String?
    let course_code: String?
    let workflow_state: CourseWorkflowState?
    let account_id: String?
    // let root_account_id: String?
    // let enrollment_term_id: String?
    // let grading_standard_id: String?
    let start_at: Date?
    let end_at: Date?
    let locale: String?
    var enrollments: [APIEnrollment]?
    // let total_students: Int? // include[]=total_students
    // let calendar: ?
    let default_view: CourseDefaultView?
    let syllabus_body: String? // include[]=syllabus_body
    // let needs_grading_count: Int? // include[]=needs_grading_count
    let term: Term? // include[]=term
    // let course_progress: ?
    // let apply_assignment_group_weights: Bool?
    let permissions: Permissions?
    // let is_public: Bool?
    // let is_public_to_auth_users: Bool?
    // let public_syllabus: Bool?
    // let public_syllabus_to_auth: Bool?
    // let public_description: String?
    // let storage_quota_mb: Double?
    // let storage_quota_used_mb: Double? // include[]=storage_quota_used_mb
    let hide_final_grades: Bool?
    // let license: String?
    // let allow_student_assignment_edits: Bool?
    // let allow_wiki_comments: Bool?
    // let allow_student_forum_attachments: Bool?
    // let open_enrollment: Bool?
    // let self_enrollment: Bool?
    // let restrict_enrollments_to_course_dates: Bool?
    // let course_format: String?
    let access_restricted_by_date: Bool?
    // let time_zone: TimeZone?
    // let blueprint: Bool?
    // let blueprint_restrictions: ?
    // let blueprint_restrictions_by_object_type: ?
    let image_download_url: String? // include[]=course_image, api sometimes returns an empty string instead of nil so don't use URL
    let is_favorite: Bool? // include[]=favorites
    // let sections: [APISection]? // include[]=sections

    // https://canvas.instructure.com/doc/api/courses.html#Term
    public struct Term: Codable, Equatable {
        let id: ID
        let name: String
        let start_at: Date?
        let end_at: Date?
    }

    public struct Permissions: Codable, Equatable {
        let create_announcement: Bool
        let create_discussion_topic: Bool
    }
}

public enum CourseDefaultView: String, Codable {
    case assignments, feed, modules, syllabus, wiki
}

public enum CourseWorkflowState: String, Codable {
    case available, completed, deleted, unpublished
}

#if DEBUG
extension APICourse {
    public static func make(
        id: ID = "1",
        name: String? = "Course One",
        course_code: String? = "C1",
        workflow_state: CourseWorkflowState? = nil,
        account_id: String? = nil,
        start_at: Date? = nil,
        end_at: Date? = nil,
        locale: String? = nil,
        enrollments: [APIEnrollment]? = [ .make(
            id: nil,
            enrollment_state: .active,
            user_id: "12",
            role: "StudentEnrollment",
            role_id: "3"
        ), ],
        default_view: CourseDefaultView? = nil,
        syllabus_body: String? = nil,
        term: Term? = nil,
        permissions: Permissions? = nil,
        hide_final_grades: Bool? = false,
        access_restricted_by_date: Bool? = nil,
        image_download_url: String? = nil,
        is_favorite: Bool? = nil
    ) -> APICourse {
        return APICourse(
            id: id,
            name: name,
            course_code: course_code,
            workflow_state: workflow_state,
            account_id: account_id,
            start_at: start_at,
            end_at: end_at,
            locale: locale,
            enrollments: enrollments,
            default_view: default_view,
            syllabus_body: syllabus_body,
            term: term,
            permissions: permissions,
            hide_final_grades: hide_final_grades,
            access_restricted_by_date: access_restricted_by_date,
            image_download_url: image_download_url,
            is_favorite: is_favorite
        )
    }
}

extension APICourse.Term {
    public static func make(
        id: String = "1",
        name: String = "Term One",
        start_at: Date? = nil,
        end_at: Date? = nil
    ) -> APICourse.Term {
        return APICourse.Term(
            id: ID(id),
            name: name,
            start_at: start_at,
            end_at: end_at
        )
    }
}
#endif

// https://canvas.instructure.com/doc/api/courses.html#method.courses.index
public struct GetCoursesRequest: APIRequestable {
    public typealias Response = [APICourse]

    public enum EnrollmentState: String {
        case active, invited_or_pending, completed
    }

    public enum EnrollmentType: String {
        case teacher, student, ta, observer, designer
    }

    public enum State: String {
        case available, completed, unpublished
    }

    public enum Include: String {
        case course_image
        case current_grading_period_scores
        case favorites
        case needs_grading_count
        case observed_users
        case permissions
        case sections
        case syllabus_body
        case tabs
        case term
        case total_scores
    }
    public static let defaultIncludes: [Include] = [
        .course_image,
        .current_grading_period_scores,
        .favorites,
        .observed_users,
        .sections,
        .term,
        .total_scores,
    ]

    let enrollmentState: EnrollmentState?
    let enrollmentType: EnrollmentType?
    let state: [State]?
    let include: [Include]
    let perPage: Int
    let studentID: String?

    public init(
        enrollmentState: EnrollmentState? = .active,
        enrollmentType: EnrollmentType? = nil,
        state: [State]? = nil,
        include: [Include] = Self.defaultIncludes,
        perPage: Int = 10,
        studentID: String? = nil
    ) {
        self.enrollmentState = enrollmentState
        self.enrollmentType = enrollmentType
        self.state = state
        self.include = include
        self.perPage = perPage
        self.studentID = studentID
    }

    public var path: String {
        var prefix = ""
        if let studentID = studentID {
            prefix = "users/\(studentID)/"
        }
        return "\(prefix)courses"
    }

    public var query: [APIQueryItem] {
        [
            .include(include.map { $0.rawValue }),
            .perPage(perPage),
            .optionalValue("enrollment_state", enrollmentState?.rawValue),
            .array("state", (state ?? []).map { $0.rawValue }),
            .optionalValue("enrollment_type", enrollmentType?.rawValue),
        ]
    }
}

// https://canvas.instructure.com/doc/api/courses.html#method.courses.show
public struct GetCourseRequest: APIRequestable {
    public typealias Response = APICourse

    public enum Include: String, CaseIterable {
        case courseImage = "course_image"
        case currentGradingPeriodScores = "current_grading_period_scores"
        case favorites
        case permissions
        case sections
        case syllabusBody = "syllabus_body"
        case term
        case totalScores = "total_scores"
        case observedUsers = "observed_users"
    }

    let courseID: String
    public static let defaultIncludes: [Include] = [
        .courseImage,
        .currentGradingPeriodScores,
        .favorites,
        .permissions,
        .sections,
        .syllabusBody,
        .term,
        .totalScores,
        .observedUsers,
    ]

    var include: [Include] = defaultIncludes

    init(courseID: String, include: [Include] = defaultIncludes) {
        self.courseID = courseID
        self.include = include
    }

    public var path: String {
        return Context(.course, id: courseID).pathComponent
    }

    public var query: [APIQueryItem] {
        [ .include(include.map { $0.rawValue }) ]
    }
}

struct APICourseParameters: Codable, Equatable {
    let name: String
    let default_view: CourseDefaultView
}

// https://canvas.instructure.com/doc/api/courses.html#method.courses.update
struct PutCourseRequest: APIRequestable {
    typealias Response = APICourse
    struct Body: Codable, Equatable {
        let course: APICourseParameters
    }

    let courseID: String

    let body: Body?
    let headers: [String: String?] = [
        "Content-Type": "application/json",
    ]
    let method = APIMethod.put
    var path: String {
        return Context(.course, id: courseID).pathComponent
    }
}

// https://canvas.instructure.com/doc/api/courses.html#method.courses.create
struct PostCourseRequest: APIRequestable {
    typealias Response = APICourse
    struct Body: Codable, Equatable {
        let course: APICourseParameters
        let offer: Bool = true
    }

    let accountID: String
    let body: Body?

    let headers: [String: String?] = [
        "Content-Type": "application/json",
    ]
    let method = APIMethod.post
    var path: String {
        return "\(Context(.account, id: accountID).pathComponent)/courses"
    }
}

// https://canvas.instructure.com/doc/api/courses.html#method.courses.api_settings
struct GetCourseSettingsRequest: APIRequestable {
    typealias Response = [String: Bool]

    let courseID: String

    var path: String {
        return "courses/\(courseID)/settings"
    }
}
