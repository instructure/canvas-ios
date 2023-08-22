//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import Core

// https://canvas.instructure.com/doc/api/courses.html#method.courses.create
struct CreateDSCourseRequest: APIRequestable {
    public typealias Response = DSCourse

    public let method = APIMethod.post
    public var path: String
    public let body: Body?

    public init(body: Body, isK5: Bool = false) {
        self.body = body
        let accountId = isK5 ? Secret.k5SubAccountId.string! : "self"
        self.path = "accounts/\(accountId)/courses"
    }
}

extension CreateDSCourseRequest {
    public struct RequestedDSCourse: Encodable {
        let name: String
        let time_zone: String = "Europe/Budapest"
        let syllabus_body: String?
        let start_at: Date?
        let end_at: Date?

        public init(name: String, syllabus_body: String? = nil, start_at: Date? = nil, end_at: Date? = nil) {
            self.name = name
            self.syllabus_body = syllabus_body
            self.start_at = start_at
            self.end_at = end_at
        }
    }

    public struct Body: Encodable {
        let course: RequestedDSCourse
        let offer = true // makes the course published after creation

        public init(course: RequestedDSCourse) {
            self.course = course
        }
    }
}
