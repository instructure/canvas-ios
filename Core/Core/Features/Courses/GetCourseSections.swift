//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

public class GetCourseSections: CollectionUseCase {
    public typealias Model = CourseSection
    public typealias Response = Request.Response

    let courseID: String
    let perPage: Int

    public init(courseID: String, perPage: Int = 100) {
        self.courseID = courseID
        self.perPage = perPage
    }

    public var cacheKey: String? {
        return "get-courses-\(courseID)-sections"
    }

    public var request: GetCourseSectionsRequest {
        return GetCourseSectionsRequest(courseID: courseID, perPage: perPage)
    }

    public var scope: Scope {
        return Scope.where(#keyPath(CourseSection.courseID), equals: courseID, orderBy: #keyPath(CourseSection.name), ascending: true, naturally: true)
    }
}
