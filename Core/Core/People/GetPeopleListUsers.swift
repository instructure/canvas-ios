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

public class GetPeopleListUsers: CollectionUseCase {
    public typealias Model = PeopleListUser

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
            return Scope.where(#keyPath(PeopleListUser.courseID), equals: context.id, orderBy: #keyPath(PeopleListUser.sortableName))
        } else if context.contextType == .group {
            return Scope.where(#keyPath(PeopleListUser.groupID), equals: context.id, orderBy: #keyPath(PeopleListUser.sortableName))
        }
        return .all(orderBy: #keyPath(PeopleListUser.sortableName))
    }

    public func write(response: [APIUser]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response else { return }
        for item in response {
            let courseId = context.contextType == .course ? context.id : nil
            let groupId = context.contextType == .group ? context.id : nil
            PeopleListUser.save(item, courseId: courseId, groupId: groupId, in: client)
        }
    }
}
