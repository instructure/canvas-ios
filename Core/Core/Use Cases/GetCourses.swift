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
    init(env: AppEnvironment) {
        let request = GetCoursesRequest(includeUnpublished: true)
        super.init(api: env.api, database: env.database, request: request)
    }

    override var predicate: NSPredicate {
        return .all
    }

    override func predicate(forItem item: APICourse) -> NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(Course.id), item.id)
    }

    override func updateModel(_ model: Course, using item: APICourse, in client: PersistenceClient) throws {
        if model.id.isEmpty { model.id = item.id }
        model.name = item.name
        model.isFavorite = item.is_favorite ?? false
        model.courseCode = item.course_code
        model.imageDownloadURL = item.image_download_url
    }
}

public class GetCourses: OperationSet {
    public init(env: AppEnvironment, force: Bool = false) {
        let paginated = GetPaginatedCourses(env: env)
        let ttl = TTLOperation(key: "get-courses", database: env.database, operation: paginated, force: force)
        super.init(operations: [ttl])
    }
}
