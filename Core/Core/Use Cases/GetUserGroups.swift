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

public class GetUserGroups: CollectionUseCase<GetGroupsRequest, Group> {
    public init(api: API, database: Persistence, force: Bool = false) {
        let request = GetGroupsRequest(context: ContextModel.currentUser)
        super.init(api: api, database: database, request: request)
    }

    override var predicate: NSPredicate {
        return NSPredicate(format: "%K == YES", "member")
    }

    public override func predicate(forItem item: APIGroup) -> NSPredicate {
        return .id(item.id.value)
    }

    override func updateModel(_ model: Group, using object: APIGroup, in client: Persistence) {
        if model.id.isEmpty { model.id = object.id.value }
        model.name = object.name
        model.member = true
        model.concluded = object.concluded
    }
}
