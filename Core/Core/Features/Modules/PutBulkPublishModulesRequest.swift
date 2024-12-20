//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

struct PutBulkPublishModulesRequest: APIRequestable {
    struct Body: CodableEquatable {
        let module_ids: [String]
        let event: String
        let skip_content_tags: Bool
        let async: Bool
    }
    struct Response: CodableEquatable {
        struct Progress: CodableEquatable {
            struct Progress: CodableEquatable {
                let id: String
            }
            let progress: Progress?
        }
        let progress: Progress?
    }

    let path: String
    let body: Body?
    let method: APIMethod = .put

    init(
        courseId: String,
        moduleIds: [String],
        action: ModulePublishAction
    ) {
        path = "courses/\(courseId)/modules"
        body = .init(
            module_ids: moduleIds,
            event: action.isPublish ? "publish" : "unpublish",
            skip_content_tags: (action.subject == .onlyModules ? true : false),
            async: true
        )
    }
}
