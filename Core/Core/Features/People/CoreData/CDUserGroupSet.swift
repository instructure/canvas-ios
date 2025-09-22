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

/// A user group set is a container for user groups.
public final class CDUserGroupSet: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var courseId: String

    // MARK: - Relationships

    /// Groups in this set. Delete rule is cascade so deleting the group set will delete all groups in it.
    @NSManaged public var userGroups: Set<CDUserGroup>

    @discardableResult
    public static func save(
        _ item: GetUserGroupsResponse.GroupSet,
        courseId: String,
        in context: NSManagedObjectContext
    ) -> CDUserGroupSet {
        let groupSet: CDUserGroupSet = context.first(
            where: #keyPath(CDUserGroupSet.id),
            equals: item._id
        ) ?? context.insert()
        groupSet.id = item._id
        groupSet.name = item.name
        groupSet.courseId = courseId

        for groupData in item.groups {
            let group = CDUserGroup.save(
                groupData,
                parentGroupSet: groupSet,
                in: context
            )
            group.parentGroupSet = groupSet
        }

        return groupSet
    }
}
