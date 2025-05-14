//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

public class GetContextUsers: CollectionUseCase {
    public typealias Model = User

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
            return Scope.where(#keyPath(User.courseID), equals: context.id, orderBy: #keyPath(User.sortableName))
        } else if context.contextType == .group {
            return Scope.where(#keyPath(User.groupID), equals: context.id, orderBy: #keyPath(User.sortableName))
        }
        return .all(orderBy: #keyPath(User.sortableName))
    }

    public func write(response: [APIUser]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response else { return }
        for item in response {
            let user = User.save(item, in: client)
            if context.contextType == .course {
                user.courseID = context.id
            } else if context.contextType == .group {
                user.groupID = context.id
            }
        }
    }
}

public enum BaseEnrollmentType: String, CaseIterable {
    case designer, observer, student, ta, teacher

    var name: String {
        switch self {
        case .designer:
            return String(localized: "Designers", bundle: .core)
        case .observer:
            return String(localized: "Observers", bundle: .core)
        case .student:
            return String(localized: "Students", bundle: .core)
        case .ta:
            return String(localized: "Teaching Assistants", bundle: .core)
        case .teacher:
            return String(localized: "Teachers", bundle: .core)
        }
    }
}

public struct GetContextUsersRequest: APIRequestable {
    public typealias Response = [APIUser]

    let context: Context
    let enrollment_type: BaseEnrollmentType?
    let search_term: String?

    public var path: String {
        return "\(context.pathComponent)/users"
    }

    public var query: [APIQueryItem] {
        [
            .value("exclude_inactive", "true"),
            .value("sort", "username"),
            .perPage(50),
            .include(["avatar_url", "enrollments"]),
            .optionalValue("enrollment_type", enrollment_type?.rawValue),
            .optionalValue("search_term", search_term)
        ]
    }
}
