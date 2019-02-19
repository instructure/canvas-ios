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

    let courseID: String

    public var path: String {
        return ContextModel(.course, id: courseID).pathComponent
    }
    public let query: [APIQueryItem] = [
        .array("include", [
            "course_image",
            "current_grading_period_scores",
            "favorites",
            "permissions",
            "sections",
            "term",
            "total_scores",
        ]),
    ]
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
