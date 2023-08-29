//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

struct UpdateDSCourseSettingsRequest: APIRequestable {
    public typealias Response = APINoContent

    public let method = APIMethod.put
    public var path: String
    public let body: Body?

    public init(body: Body, course: DSCourse) {
        self.body = body
        self.path = "courses/\(course.id)/settings"
    }
}

extension UpdateDSCourseSettingsRequest {
    public struct Body: Encodable {
        let restrict_quantitative_data: Bool

        public init(restrict_quantitative_data: Bool) {
            self.restrict_quantitative_data = restrict_quantitative_data
        }
    }
}
