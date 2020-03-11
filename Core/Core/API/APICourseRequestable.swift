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

// https://canvas.instructure.com/doc/api/courses.html#method.courses.index
public struct GetCoursesRequest: APIRequestable {
    public typealias Response = [APICourse]

    public enum EnrollmentState: String {
        case active, invited_or_pending, completed
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
    let state: [State]?
    let include: [Include]
    let perPage: Int
    let studentID: String?

    public init(
        enrollmentState: EnrollmentState? = .active,
        state: [State]? = nil,
        include: [Include] = Self.defaultIncludes,
        perPage: Int = 10,
        studentID: String? = nil
    ) {
        self.enrollmentState = enrollmentState
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
        return ContextModel(.course, id: courseID).pathComponent
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
        return ContextModel(.course, id: courseID).pathComponent
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
        return "\(ContextModel(.account, id: accountID).pathComponent)/courses"
    }
}
