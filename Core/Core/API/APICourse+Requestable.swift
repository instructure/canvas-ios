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

// https://canvas.instructure.com/doc/api/courses.html#method.courses.index
public struct GetCoursesRequest: APIRequestable {
    public typealias Response = [APICourse]

    let includeUnpublished: Bool

    public let path = "courses"
    public var query: [APIQueryItem] {
        var state = [ "available", "completed" ]
        if includeUnpublished {
            state.append("unpublished")
        }
        return [
            .array("include", [
                "course_image",
                "current_grading_period_scores",
                "favorites",
                "observed_users",
                "sections",
                "term",
                "total_scores",
            ]),
            .array("state", state),
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
        case term
        case totalScores = "total_scores"
        case syllabusBody = "syllabus_body"
    }

    let courseID: String
    public static let defaultIncludes = [
        Include.courseImage,
        Include.currentGradingPeriodScores,
        Include.favorites,
        Include.permissions,
        Include.sections,
        Include.term,
        Include.totalScores,
        Include.syllabusBody,
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
