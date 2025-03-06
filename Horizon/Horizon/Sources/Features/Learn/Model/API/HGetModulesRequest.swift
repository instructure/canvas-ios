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

import Core

struct HGetModulesRequest: APIRequestable {
    typealias Response = [APIModule]
    enum Include: String, CaseIterable {
        case content_details, items, estimated_durations
    }

    private let courseID: String
    private let include: [Include]
    private let perPage: Int?

    init(
        courseID: String,
        include: [Include] = Include.allCases,
        perPage: Int? = nil
    ) {
        self.courseID = courseID
        self.include = include
        self.perPage = perPage
    }

    var path: String {
        let context = Context(.course, id: courseID)
        return "\(context.pathComponent)/modules"
    }

    var query: [APIQueryItem] {
        var query: [APIQueryItem] = [
            .include(include.map { $0.rawValue })
        ]
        if let perPage = perPage {
            query.append(.perPage(perPage))
        }
        return query
    }
}
