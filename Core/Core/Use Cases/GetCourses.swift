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

private class GetPaginatedCourses: PaginatedUseCase<GetCoursesRequest, Course> {
    init(api: API, database: Persistence) {
        let request = GetCoursesRequest(includeUnpublished: true)
        super.init(api: api, database: database, request: request)
    }

    override var predicate: NSPredicate {
        return .all
    }

    override func predicate(forItem item: APICourse) -> NSPredicate {
        return .id(item.id)
    }

    override func updateModel(_ model: Course, using item: APICourse, in client: Persistence) throws {
        if model.id.isEmpty { model.id = item.id }
        model.name = item.name
        model.isFavorite = item.is_favorite ?? false
        model.courseCode = item.course_code
        model.imageDownloadUrl = item.image_download_url
    }
}

public class GetCourses: GroupOperation {
    public init(api: API = URLSessionAPI(), database: Persistence, force: Bool = false) {
        let paginated = GetPaginatedCourses(api: api, database: database)
        let ttl = TTLOperation(key: "get-courses", database: database, operation: paginated, force: force)
        super.init(operations: [ttl])
    }
}
