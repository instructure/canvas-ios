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

public class GetGroup: APIUseCase {
    let groupID: String
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

    public init(groupID: String, env: AppEnvironment = .shared) {
        self.groupID = groupID
    }
}
