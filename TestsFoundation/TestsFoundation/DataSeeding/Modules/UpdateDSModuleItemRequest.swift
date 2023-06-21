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

public struct UpdateDSModuleItemRequest: APIRequestable {
    public typealias Response = DSModuleItem

    public let method = APIMethod.put
    public var path: String
    public let body: Body?

    public init(body: Body, courseId: String, moduleId: String, itemId: String) {
        self.body = body
        self.path = "courses/\(courseId)/modules/\(moduleId)/items/\(itemId)"
    }
}

extension UpdateDSModuleItemRequest {
    public struct UpdatedDSModuleItem: Encodable {
        let published: Bool
    }
    public struct Body: Encodable {
        let module_item: UpdatedDSModuleItem
    }
}
