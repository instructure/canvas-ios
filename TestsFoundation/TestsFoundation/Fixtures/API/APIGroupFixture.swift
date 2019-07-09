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
@testable import Core

extension APIGroup {
    public static func make(
        id: ID = "1",
        name: String = "Group One",
        concluded: Bool = false,
        members_count: Int = 1,
        avatar_url: URL? = nil,
        course_id: ID? = nil,
        group_category_id: ID = "1",
        permissions: Permissions? = nil
    ) -> APIGroup {
        return APIGroup(
            id: id,
            name: name,
            concluded: concluded,
            members_count: members_count,
            avatar_url: avatar_url,
            course_id: course_id,
            group_category_id: group_category_id,
            permissions: permissions
        )
    }
}

extension APIGroup: APIContext {
    public var contextType: ContextType { return .group }
}
