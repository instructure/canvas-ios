//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public class GetCourseContextUsers: CollectionUseCase {
    public typealias Model = ContextUser

    let context: Context
    let type: BaseEnrollmentType?
    let search: String?

    public init(context: Context, type: BaseEnrollmentType? = nil, search: String? = nil) {
        self.context = context
        self.type = type
        self.search = search
    }

    public let cacheKey: String? = nil

    public var request: GetContextUsersRequest {
        return GetContextUsersRequest(context: context, enrollment_type: type, search_term: search)
    }

    public var scope: Scope {
        if context.contextType == .course {
            return Scope.where(#keyPath(ContextUser.courseID), equals: context.id, orderBy: #keyPath(ContextUser.sortableName))
        } else if context.contextType == .group {
            return Scope.where(#keyPath(ContextUser.groupID), equals: context.id, orderBy: #keyPath(ContextUser.sortableName))
        }
        return .all(orderBy: #keyPath(ContextUser.sortableName))
    }

    public func write(response: [APIUser]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response else { return }
        for item in response {
            var userItem = item
            if context.contextType == .course {
                userItem.course_id = context.id
            } else if context.contextType == .group {
                userItem.group_id = context.id
            }
            ContextUser.save(userItem, in: client)
        }
    }
}
