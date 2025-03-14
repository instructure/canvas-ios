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

// https://canvas.instructure.com/doc/api/search.html#method.search.recipients
public struct APISearchRecipient: Codable, Equatable {
    public let id: ID
    public let name: String
    public let full_name: String?
    public let pronouns: String?
    public let avatar_url: APIURL?
    public let type: APISearchRecipientContext?
    public let common_courses: [String: [String]]?
}

public enum APISearchRecipientContext: String, Codable {
    case context, course, group, section, user
}

#if DEBUG
extension APISearchRecipient {
    public static func make(
        id: ID = "1",
        name: String = "John Doe",
        full_name: String? = nil,
        pronouns: String? = nil,
        avatar_url: URL? = nil,
        type: APISearchRecipientContext? = .course,
        common_courses: [String: [String]] = [:]
    ) -> APISearchRecipient {
        return APISearchRecipient(
            id: id,
            name: name,
            full_name: full_name ?? name,
            pronouns: pronouns,
            avatar_url: APIURL(rawValue: avatar_url),
            type: type,
            common_courses: common_courses
        )
    }
}
#endif

public struct GetSearchRecipientsRequest: APIRequestable {
    public typealias Response = [APISearchRecipient]

    public let path = "search/recipients"
    public let query: [APIQueryItem]

    public init(
        context: Context,
        qualifier: ContextQualifier? = nil,
        search: String = "",
        userID: String? = nil,
        skipVisibilityChecks: Bool = false,
        includeContexts: Bool = false,
        perPage: Int = 50
    ) {
        var context = context.canvasContextID
        if let qualifier = qualifier {
            context.append("_\(qualifier.rawValue)")
        }
        var items: [APIQueryItem] = [
            .perPage(perPage),
            .value("context", context),
            .value("search", search),
            .value("synthetic_contexts", "1"),
            .optionalValue("user_id", userID)
        ]
        if skipVisibilityChecks {
            items.append(.bool("skip_visibility_checks", true))
        }
        if !includeContexts {
            items.append(.value("type", "user"))
        }
        query = items
    }
}
