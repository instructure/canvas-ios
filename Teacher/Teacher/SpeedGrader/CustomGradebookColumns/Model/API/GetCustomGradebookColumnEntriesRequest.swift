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

import Foundation
import Core

// https://developerdocs.instructure.com/services/canvas/file.all_resources/custom_gradebook_columns#method.custom_gradebook_column_data_api.index
struct GetCustomGradebookColumnEntriesRequest: APIRequestable {
    typealias Response = [APICustomGradebookColumnEntry]

    var method: APIMethod { .get }
    var path: String {
        "courses/\(courseId)/custom_gradebook_columns/\(columnId)/data"
    }

    internal let courseId: String
    internal let columnId: String

    init(courseId: String, columnId: String) {
        self.courseId = courseId
        self.columnId = columnId
    }
}
