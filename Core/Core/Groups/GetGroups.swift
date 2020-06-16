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

class GetGroups: CollectionUseCase {
    typealias Model = Group
    let cacheKey: String?
    let request: GetGroupsRequest

    init(context: Context = Context.currentUser) {
        cacheKey = "\(context.pathComponent)/groups"
        request = GetGroupsRequest(context: context)
    }
}

public class GetGroup: APIUseCase {
    public let groupID: String
    public typealias Model = Group

    public var request: GetGroupRequest {
        return GetGroupRequest(id: groupID)
    }

    public var scope: Scope {
        return Scope(predicate: NSPredicate(format: "%K == %@", #keyPath(Group.id), groupID), order: [])
    }

    public var cacheKey: String? {
        return "get-group-\(groupID)"
    }

    public init(groupID: String) {
        self.groupID = groupID
    }
}

public struct GetDashboardGroups: CollectionUseCase {
    public typealias Model = Group

    public init() {}

    public var request: GetGroupsRequest {
        return GetGroupsRequest(context: .currentUser)
    }

    public var scope: Scope {
        return .where(#keyPath(Group.showOnDashboard), equals: true, orderBy: #keyPath(Group.name))
    }

    public let cacheKey: String? = "get-user-groups"
}
