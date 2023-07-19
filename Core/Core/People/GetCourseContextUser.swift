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

import CoreData

public struct GetCourseContextUser: APIUseCase {
    public typealias Model = ContextUser
    let context: Context
    let userID: String

    public init(context: Context, userID: String) {
        self.context = context
        self.userID = userID
    }

    public var request: GetCourseContextUserRequest {
        return GetCourseContextUserRequest(context: context, userID: userID)
    }

    public var cacheKey: String? {
        return "get-context-user-\(context.id)-\(userID)"
    }

    public var scope: Scope { Scope(
        predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(key: #keyPath(ContextUser.id), equals: userID),
        ]), order: [])}
}

public struct GetCourseContextUserRequest: APIRequestable {
    public typealias Response = APIUser

    let context: Context
    let userID: String

    public var path: String { "\(context.pathComponent)/users/\(userID)" }
    public var query: [APIQueryItem] { [.include(["avatar_url", "enrollments", "email"])] }
}
