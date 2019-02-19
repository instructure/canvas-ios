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
        let context = ContextModel(.group, id: groupID)
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
        return ContextModel(.group, id: id).pathComponent
    }
}
