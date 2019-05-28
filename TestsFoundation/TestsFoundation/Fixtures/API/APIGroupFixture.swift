//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
