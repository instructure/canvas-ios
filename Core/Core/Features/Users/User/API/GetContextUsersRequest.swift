//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
