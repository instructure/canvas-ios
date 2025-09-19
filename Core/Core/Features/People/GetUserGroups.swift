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

public class GetUserGroups: CollectionUseCase {
    public typealias Model = CDUserGroup
    public typealias Response = GetUserGroupsResponse

    public let scope: Scope
    public let request: GetUserGroupsRequest
    public let cacheKey: String?
    private let courseId: String

    /// - Parameters:
    ///   - filterToDifferentiationTags: If true, only returns groups that are differentiation tags (non-collaborative groups).
    ///                                  If false (default), returns all groups for the course regardless of group type.
    public init(courseId: String, filterToDifferentiationTags: Bool = false) {
        self.courseId = courseId
        self.cacheKey = "user-groups-\(courseId)"
        self.request = GetUserGroupsRequest(courseId: courseId)

        var predicates = [NSPredicate(format: "%K == %@", #keyPath(CDUserGroup.parentGroupSet.courseId), courseId)]

        if filterToDifferentiationTags {
            predicates.append(NSPredicate(format: "%K == YES", #keyPath(CDUserGroup.isDifferentiationTag)))
        }

        self.scope = Scope(
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates),
            order: [NSSortDescriptor(key: #keyPath(CDUserGroup.name), ascending: true)]
        )
    }

    public func write(
        response: GetUserGroupsResponse?,
        urlResponse: URLResponse?,
        to client: NSManagedObjectContext
    ) {
        guard let response else { return }

        for groupSetData in response.groupSets {
            let groupSet = CDUserGroupSet.save(groupSetData, courseId: courseId, in: client)
            for groupData in groupSetData.groups {
                CDUserGroup.save(groupData, parentGroupSet: groupSet, in: client)
            }
        }
    }
}
