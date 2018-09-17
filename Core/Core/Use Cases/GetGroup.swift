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

    init(groupID: String, api: API = URLSessionAPI(), database: Persistence) {
        self.groupID = groupID
        let request = GetGroupRequest(id: groupID)
        super.init(api: api, database: database, request: request)
    }

    override public var predicate: NSPredicate {
        return .id(groupID)
    }

    override public func updateModel(_ model: Group, using item: APIGroup, in client: Persistence) throws {
        if model.id.isEmpty { model.id = item.id.value }
        model.name = item.name
        model.member = true
        model.concluded = item.concluded
    }
}
