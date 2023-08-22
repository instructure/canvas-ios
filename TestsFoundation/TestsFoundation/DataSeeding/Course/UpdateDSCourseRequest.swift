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

struct UpdateDSCourseRequest: APIRequestable {
    public typealias Response = APINoContent

    public let method = APIMethod.put
    public var path: String
    public let body: Body?

    public init(body: Body, courseId: String) {
        self.body = body
        self.path = "courses/\(courseId)"
    }
}

extension UpdateDSCourseRequest {
    public struct UpdatedDSCourse: Encodable {
        let grading_standard_id: Int?
        let homeroom_course: Bool?

        public init(grading_standard_id: Int? = nil, homeroom_course: Bool? = nil) {
            self.grading_standard_id = grading_standard_id
            self.homeroom_course = homeroom_course
        }
    }

    public struct Body: Encodable {
        let course: UpdatedDSCourse

        public init(course: UpdatedDSCourse) {
            self.course = course
        }
    }
}
