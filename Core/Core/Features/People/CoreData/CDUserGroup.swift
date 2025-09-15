//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import CoreData

public final class CDUserGroup: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var name: String
    /// If this property is `false`, then this is a public user group.
    @NSManaged public var isDifferentiationTag: Bool
    public var isSingleTag: Bool {
        name == parentGroupSet.name
    }

    // MARK: - Relationships

    @NSManaged public var parentGroupSet: CDUserGroupSet
    /// Store user IDs, so in case the `User` object is not in the database yet, we can still setup the relationship later.
    @NSManaged public var userIdsInGroup: Set<String>
    @NSManaged public var usersInGroup: Set<User>

    @discardableResult
    public static func save(
        _ item: GetUserGroupsResponse.Group,
        parentGroupSet: CDUserGroupSet,
        in context: NSManagedObjectContext
    ) -> CDUserGroup {
        let group: CDUserGroup = context.first(
            where: #keyPath(CDUserGroup.id),
            equals: item._id
        ) ?? context.insert()
        group.id = item._id
        group.name = item.name
        group.isDifferentiationTag = item.nonCollaborative
        group.parentGroupSet = parentGroupSet
        group.userIdsInGroup = Set(item.userIds)

        group.connectUsersToGroups(in: context)

        return group
    }

    private func connectUsersToGroups(
        in context: NSManagedObjectContext
    ) {
        let predicate = NSPredicate(
            format: "%K IN %@",
            #keyPath(User.id),
            userIdsInGroup
        )

        let usersInGroup: [User] = context.fetch(scope: .init(predicate: predicate, order: []))
        self.usersInGroup = Set(usersInGroup)
    }
}
