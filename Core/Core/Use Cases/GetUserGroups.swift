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

public struct GetUserGroups: CollectionUseCase {
    public typealias Model = Group

    public init() {}

    public var request: GetGroupsRequest {
        return GetGroupsRequest(context: ContextModel.currentUser)
    }

    public var scope: Scope {
        return .where(#keyPath(Group.showOnDashboard), equals: true, orderBy: #keyPath(Group.name))
    }

    public let cacheKey: String? = "get-user-groups"
}
