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

    let enrollmentState: EnrollmentState?
    let state: [State]?
    let perPage: Int

    public init(enrollmentState: EnrollmentState? = .active, state: [State]? = nil, perPage: Int = 10) {
        self.enrollmentState = enrollmentState
        self.state = state
        self.perPage = perPage
    }

    public let path = "courses"
    public var query: [APIQueryItem] {
        var query: [APIQueryItem] = [
            .array("include", [
                "course_image",
                "current_grading_period_scores",
                "favorites",
                "observed_users",
                "sections",
                "term",
                "total_scores",
            ]),
            .value("per_page", String(perPage)),
        ]
        if let enrollmentState = enrollmentState {
            query.append(.value("enrollment_state", enrollmentState.rawValue))
        }
        if let state = state {
            query.append(.array("state", state.map { $0.rawValue }))
        }
        return query
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
        var query: [APIQueryItem] = []

        if !include.isEmpty {
            query.append(.array("include", include.map { $0.rawValue }))
        }
        return query
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
