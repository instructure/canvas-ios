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

// https://canvas.instructure.com/doc/api/groups.html#Group
public struct APIGroup: Codable, Equatable {
    public let id: ID
    let name: String
    let concluded: Bool
    // let description: String?
    // let is_public: Bool
    // let followed_by_user: Bool
    // let join_level: JoinLevel
    let members_count: Int
    let avatar_url: URL?
    // let context_type: String
    let course_id: ID?
    // let role: String?
    let group_category_id: ID
    // let sis_group_id: String?
    // let sis_import_id: String?
    // let storage_quota_mb: String
    let permissions: Permissions?

    public struct Permissions: Codable, Equatable {
        let create_announcement: Bool
        let create_discussion_topic: Bool
    }
}

#if DEBUG
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
#endif

// https://canvas.instructure.com/doc/api/groups.html#method.groups.index
// https://canvas.instructure.com/doc/api/groups.html#method.groups.context_index
public struct GetGroupsRequest: APIRequestable {
    public typealias Response = [APIGroup]

    let context: Context

    public var path: String {
        return "\(context.pathComponent)/groups"
    }

    public let query: [APIQueryItem] = [
        .array("include", [
            "users",
        ]),
    ]
}

// https://canvas.instructure.com/doc/api/groups.html#method.groups.users
struct GetGroupUsersRequest: APIRequestable {
    typealias Response = [APIUser]

    let groupID: String

    var path: String {
        let context = Context(.group, id: groupID)
        return "\(context.pathComponent)/users"
    }

    public let query: [APIQueryItem] = [
        .array("include", [
            "avatar_url",
        ]),
    ]
}

// https://canvas.instructure.com/doc/api/groups.html#method.groups.show
public struct GetGroupRequest: APIRequestable {
    public typealias Response = APIGroup

    let id: String

    public var path: String {
        return Context(.group, id: id).pathComponent
    }
}
