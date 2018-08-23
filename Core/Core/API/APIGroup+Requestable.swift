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
struct GetGroupsRequest: APIRequestable {
    typealias Response = [APIGroup]

    let context: Context

    var path: String {
        return "\(context.pathComponent)/groups?include[]=users"
    }
}

// https://canvas.instructure.com/doc/api/groups.html#method.groups.users
struct GetGroupUsersRequest: APIRequestable {
    typealias Response = [APIUser]

    let groupID: String

    var path: String {
        let context = ContextModel(.group, id: groupID)
        return "\(context.pathComponent)/users?include[]=avatar_url"
    }
}
