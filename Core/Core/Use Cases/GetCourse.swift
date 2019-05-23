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

public class GetCourse: APIUseCase {
    public typealias Model = Course

    public let courseID: String
    private let include: [GetCourseRequest.Include]

    public init(courseID: String, include: [GetCourseRequest.Include] = GetCourseRequest.defaultIncludes) {
        self.courseID = courseID
        self.include = include
    }

    public var cacheKey: String? {
        return "get-course-\(courseID)"
    }

    public var scope: Scope {
        return .where(#keyPath(Course.id), equals: courseID)
    }

    public var request: GetCourseRequest {
        return GetCourseRequest(courseID: courseID, include: include)
    }
}
