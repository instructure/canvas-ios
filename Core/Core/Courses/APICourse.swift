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
    /** Teacher assigned course color for K5 in hex format. */
    let course_color: String?
    let workflow_state: CourseWorkflowState?
    let account_id: String?
    // let root_account_id: String?
    // let enrollment_term_id: String?
    // let grading_standard_id: String?
    let start_at: Date?
    let end_at: Date?
    let locale: String?
    var enrollments: [APIEnrollment]?
    var grading_periods: [APIGradingPeriod]?
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
    let homeroom_course: Bool?
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
    let banner_image_download_url: String?
    let image_download_url: String? // include[]=course_image, api sometimes returns an empty string instead of nil so don't use URL
    var is_favorite: Bool? // include[]=favorites
    let sections: [SectionRef]? // include[]=sections
    let tabs: [APITab]? // include[]=tabs

    public var context: Context { Context(.course, id: id.rawValue) }

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

    public struct SectionRef: Codable, Equatable {
        let end_at: Date?
        let id: ID
        let name: String
        let start_at: Date?
    }
}

public struct APICourseSettings: Codable {
    let usage_rights_required: Bool
    // let home_page_announcement_limit: Int
    let syllabus_course_summary: Bool
}

public enum CourseDefaultView: String, Codable, CaseIterable {
    case assignments, feed, modules, syllabus, wiki

    var string: String {
        switch self {
        case .assignments:
            return NSLocalizedString("Assignments List", comment: "")
        case .feed:
            return NSLocalizedString("Course Activity Stream", comment: "")
        case .modules:
            return NSLocalizedString("Course Modules", comment: "")
        case .syllabus:
            return NSLocalizedString("Syllabus", comment: "")
        case .wiki:
            return NSLocalizedString("Pages Front Page", comment: "")
        }
    }
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
        course_color: String? = nil,
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
        grading_periods: [APIGradingPeriod]? = [],
        default_view: CourseDefaultView? = nil,
        syllabus_body: String? = nil,
        term: Term? = nil,
        permissions: Permissions? = nil,
        hide_final_grades: Bool? = false,
        homeroom_course: Bool? = false,
        access_restricted_by_date: Bool? = nil,
        banner_image_download_url: String? = nil,
        image_download_url: String? = nil,
        is_favorite: Bool? = nil,
        sections: [SectionRef]? = nil,
        tabs: [APITab]? = nil
    ) -> APICourse {
        return APICourse(
            id: id,
            name: name,
            course_code: course_code,
            course_color: course_color,
            workflow_state: workflow_state,
            account_id: account_id,
            start_at: start_at,
            end_at: end_at,
            locale: locale,
            enrollments: enrollments,
            grading_periods: grading_periods,
            default_view: default_view,
            syllabus_body: syllabus_body,
            term: term,
            permissions: permissions,
            hide_final_grades: hide_final_grades,
            homeroom_course: homeroom_course,
            access_restricted_by_date: access_restricted_by_date,
            banner_image_download_url: banner_image_download_url,
            image_download_url: image_download_url,
            is_favorite: is_favorite,
            sections: sections,
            tabs: tabs
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

extension APICourseSettings {
    static func make(
        usage_rights_required: Bool = false,
        syllabus_course_summary: Bool = true
    ) -> APICourseSettings {
        return APICourseSettings(
            usage_rights_required: usage_rights_required,
            syllabus_course_summary: syllabus_course_summary
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
        case available, completed, unpublished, current_and_concluded
    }

    private enum Include: String, CaseIterable {
        case banner_image
        case course_image
        case current_grading_period_scores
        case favorites
        case grading_periods
        case needs_grading_count
        case observed_users
        case sections
        case syllabus_body
        case tabs
        case term
        case total_scores
    }

    let enrollmentState: EnrollmentState?
    let enrollmentType: EnrollmentType?
    let state: [State]?
    let perPage: Int
    let studentID: String?

    public init(
        enrollmentState: EnrollmentState? = .active,
        enrollmentType: EnrollmentType? = nil,
        state: [State]? = nil,
        perPage: Int = 10,
        studentID: String? = nil
    ) {
        self.enrollmentState = enrollmentState
        self.enrollmentType = enrollmentType
        self.state = state
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
            .include(Include.allCases.map { $0.rawValue }),
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
        case courseBannerImage = "banner_image"
        case currentGradingPeriodScores = "current_grading_period_scores"
        case favorites
        case permissions
        case sections
        case syllabusBody = "syllabus_body"
        case term
        case totalScores = "total_scores"
        case observedUsers = "observed_users"
        case tabs = "tabs"
    }

    let courseID: String
    public static let defaultIncludes: [Include] = [
        .courseBannerImage,
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
    let name: String?
    let default_view: CourseDefaultView?
    let syllabus_body: String?
    let syllabus_course_summary: Bool?
}

// https://canvas.instructure.com/doc/api/courses.html#method.courses.update
public struct PutCourseRequest: APIRequestable {
    public typealias Response = APICourse
    public struct Body: Codable, Equatable {
        let course: APICourseParameters
    }

    public let courseID: String
    public let body: Body?
    public let method = APIMethod.put
    public var path: String {
        return Context(.course, id: courseID).pathComponent
    }

    public init(courseID: String, courseName: String?, defaultView: CourseDefaultView?, syllabusBody: String?, syllabusSummary: Bool?) {
        self.courseID = courseID
        let params = APICourseParameters(
            name: courseName,
            default_view: defaultView,
            syllabus_body: syllabusBody,
            syllabus_course_summary: syllabusSummary)
        self.body = Body(course: params)
    }

    public init(courseID: String, body: Body) {
        self.courseID = courseID
        self.body = body
    }
}

// https://canvas.instructure.com/doc/api/courses.html#method.courses.create
struct PostCourseRequest: APIRequestable {
    typealias Response = APICourse
    struct Body: Codable, Equatable {
        let course: APICourseParameters
        var offer: Bool = true
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
public struct GetCourseSettingsRequest: APIRequestable {
    public typealias Response = APICourseSettings

    let courseID: String

    public var path: String { "courses/\(courseID)/settings" }
}
