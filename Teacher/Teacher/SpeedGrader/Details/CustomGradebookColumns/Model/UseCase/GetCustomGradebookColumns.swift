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

import Core
import CoreData
import Foundation

final class GetCustomGradebookColumns: CollectionUseCase {
    typealias Model = CDCustomGradebookColumn

    private let courseId: String

    init(courseId: String) {
        self.courseId = courseId
    }

    var cacheKey: String? {
        "courses/\(courseId)/custom_gradebook_columns"
    }

    var scope: Scope {
        .where(
            #keyPath(CDCustomGradebookColumn.courseId),
            equals: courseId,
            orderBy: #keyPath(CDCustomGradebookColumn.position)
        )
    }

    var request: GetCustomGradebookColumnsRequest {
        GetCustomGradebookColumnsRequest(courseId: courseId)
    }

    func write(response: GetCustomGradebookColumnsRequest.Response?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        response?.forEach {
            CDCustomGradebookColumn.save($0, courseId: courseId, in: client)
        }
    }
}
