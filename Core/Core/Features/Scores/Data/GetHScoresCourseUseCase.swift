//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import CoreData

public class GetHScoresCourseUseCase: APIUseCase {
    public typealias Model = CDHScoresCourse

    public let courseID: String
    private let include: [GetCourseRequest.Include]

    public init(
        courseID: String,
        include: [GetCourseRequest.Include] = GetCourseRequest.defaultIncludes
    ) {
        self.courseID = courseID
        self.include = include
    }

    public var cacheKey: String? {
        return "get-score-course-\(courseID)"
    }

    public var scope: Scope {
        return .where(#keyPath(CDHScoresCourse.courseID), equals: courseID)
    }

    public var request: GetCourseRequest {
        return GetCourseRequest(courseID: courseID, include: include)
    }

    public func write(
        response: APICourse?,
        urlResponse _: URLResponse?,
        to client: NSManagedObjectContext
    ) {
        if let course = response {
            CDHScoresCourse.save(course, in: client)
        }
    }
}
