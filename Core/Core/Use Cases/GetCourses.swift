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

public class GetCourses: CollectionUseCase {
    public typealias Model = Course
    var showFavorites: Bool
    public init(showFavorites: Bool = false) {
        self.showFavorites = showFavorites
    }

    public var cacheKey: String {
        return "get-assignments"
    }

    public var request: GetCoursesRequest {
        return GetCoursesRequest(includeUnpublished: true)
    }

    public var scope: Scope {
        return showFavorites ?
            .where(#keyPath(Course.isFavorite), equals: true, orderBy: #keyPath(Course.name)) :
            .all(orderBy: #keyPath(Course.name), ascending: true, naturally: true)
    }

    public func write(response: [APICourse]?, urlResponse: URLResponse?, to client: PersistenceClient) throws {
        guard let response = response else {
            return
        }

        for item in response {
            Course.save(item, in: client)
        }
    }
}
