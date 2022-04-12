//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

// https://canvas.instructure.com/doc/api/tabs.html#Tab
public struct APITab: Codable, Equatable {
    let id: ID
    let html_url: URL
    let full_url: URL?
    let url: URL?
    let label: String
    let type: TabType
    let hidden: Bool?
    let visibility: String
    let position: Int
}

#if DEBUG
extension APITab {
    public static func make(
        id: ID = "home",
        html_url: URL = URL(string: "/groups/16")!,
        full_url: URL? = nil,
        url: URL? = nil,
        label: String = "Home",
        type: TabType = .internal,
        hidden: Bool? = nil,
        visibility: TabVisibility = .public,
        position: Int = 1
    ) -> APITab {
        return APITab(
            id: id,
            html_url: html_url,
            full_url: full_url,
            url: url,
            label: label,
            type: type,
            hidden: hidden,
            visibility: visibility.rawValue,
            position: position
        )
    }
}
#endif

// https://canvas.instructure.com/doc/api/tabs.html#method.tabs.index
public struct GetTabsRequest: APIRequestable {
    public typealias Response = [APITab]

    let context: Context
    let perPage: Int?
    let include: [Include]?

    public init (context: Context, perPage: Int? = 100, include: [Include]? = nil) {
        self.context = context
        self.perPage = perPage
        self.include = include
    }

    public enum Include: String {
        case course_subject_tabs
    }

    public var query: [APIQueryItem] {
        var query: [APIQueryItem] = [.perPage(perPage)]
        if let include = include {
            query.insert(.include(include.map { $0.rawValue }), at: 0)
        }
        return query
    }

    public var path: String {
        return "\(context.pathComponent)/tabs"
    }
}
