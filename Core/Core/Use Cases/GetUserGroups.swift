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
    public init(env: AppEnvironment, force: Bool = false) {
        let request = GetGroupsRequest(context: ContextModel.currentUser)
        super.init(api: env.api, database: env.database, request: request)
    }

    override var predicate: NSPredicate {
        return NSPredicate(format: "%K == YES", #keyPath(Group.showOnDashboard))
    }

    public override func predicate(forItem item: APIGroup) -> NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(Group.id), item.id.value)
    }

    override func updateModel(_ model: Group, using object: APIGroup, in client: PersistenceClient) {
        model.avatarURL = object.avatar_url
        model.courseID = object.course_id?.value
        model.id = object.id.value
        model.name = object.name
        model.concluded = object.concluded
        model.showOnDashboard = true
    }
}
