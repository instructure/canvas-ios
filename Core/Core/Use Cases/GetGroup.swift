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

public class GetGroup: DetailUseCase<GetGroupRequest, Group> {
    let groupID: String

    public init(groupID: String, env: AppEnvironment = .shared) {
        self.groupID = groupID
        let request = GetGroupRequest(id: groupID)
        super.init(api: env.api, database: env.database, request: request)
    }

    override public var predicate: NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(Group.id), groupID)
    }

    override public func updateModel(_ model: Group, using item: APIGroup, in client: PersistenceClient) throws {
        model.avatarURL = item.avatar_url
        model.concluded = item.concluded
        model.courseID = item.course_id?.value
        if model.id.isEmpty { model.id = item.id.value }
        model.name = item.name
    }
}
