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

public class GetCourses: CollectionUseCase {
    public typealias Model = Course

    var showFavorites: Bool
    var perPage: Int

    public init(showFavorites: Bool = false, perPage: Int = 10) {
        self.showFavorites = showFavorites
        self.perPage = perPage
    }

    public let cacheKey: String? = "get-courses"

    public var request: GetCoursesRequest {
        return GetCoursesRequest(includeUnpublished: true, perPage: self.perPage)
    }

    public var scope: Scope {
        return showFavorites ?
            .where(#keyPath(Course.isFavorite), equals: true, orderBy: #keyPath(Course.name)) :
            .all(orderBy: #keyPath(Course.name), ascending: true, naturally: true)
    }
}
