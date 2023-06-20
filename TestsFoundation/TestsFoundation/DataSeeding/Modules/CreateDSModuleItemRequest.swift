//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

// https://canvas.instructure.com/doc/api/modules.html#method.context_module_items_api.create
struct CreateDSModuleItemRequest: APIRequestable {
    public typealias Response = DSModuleItem

    public let method = APIMethod.post
    public var path: String
    public let body: Body?

    public init(body: Body, accountId: String = "self", courseId: String, moduleId: String) {
        self.body = body
        self.path = "accounts/\(accountId)/courses/\(courseId)/modules/\(moduleId)/items"
    }
}

extension CreateDSModuleItemRequest {
    public struct RequestedDSModuleItem: Encodable {
        let title: String
        let type: DSModuleItemType
        let content_id: String

        public init(title: String = "Module Item Name",
                    type: DSModuleItemType = .Assignment,
                    content_id: String = "1") {
            self.title = title
            self.type = type
            self.content_id = content_id
        }
    }

    public struct Body: Encodable {
        let moduleItem: RequestedDSModuleItem

        public init(moduleItem: RequestedDSModuleItem) {
            self.moduleItem = moduleItem
        }
    }
}
