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

public class GetCourses: CollectionUseCase<GetCoursesRequest, Course> {
    public init(api: API, database: DatabaseStore) {
        let request = GetCoursesRequest(includeUnpublished: true)
        super.init(api: api, database: database, request: request)
    }

    override var predicate: NSPredicate {
        return .all
    }

    override func predicate(forItem item: APICourse) -> NSPredicate {
        return .id(item.id)
    }

    override func updateModel(_ model: Course, using item: APICourse, in client: DatabaseClient) throws {
        model.id = item.id
        model.name = item.name
        model.isFavorite = item.is_favorite ?? false
        model.courseCode = item.course_code
        model.imageDownloadUrl = item.image_download_url
    }
}
