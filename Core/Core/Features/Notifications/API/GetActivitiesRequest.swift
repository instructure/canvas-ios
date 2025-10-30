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

public struct GetActivitiesRequest: APIRequestable {
    public typealias Response = [APIActivity]
    let perPage: Int?
    let onlyActiveCourses: Bool

    public init(perPage: Int? = nil, onlyActiveCourses: Bool = true) {
        self.perPage = perPage
        self.onlyActiveCourses = onlyActiveCourses
    }

    public var path: String {
        let context = Context(.user, id: "self")
        return "\(context.pathComponent)/activity_stream"
    }

    public var query: [APIQueryItem] {
        var items: [APIQueryItem] = []

        if onlyActiveCourses {
            items.append(.value("only_active_courses", "true"))
        }

        if let perPage = perPage {
            items.append(.perPage(perPage))
        }

        return items
    }
}
