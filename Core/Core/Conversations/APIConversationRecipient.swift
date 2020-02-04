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

public struct APIConversationRecipient: Codable {
    public let id: ID
    public let name: String
    public let full_name: String?
    public let avatar_url: APIURL?
    public let pronouns: String?
}

extension APIConversationRecipient: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension APIConversationRecipient {
    public init(searchRecipient r: SearchRecipient) {
        self.id = ID(r.id)
        self.name = r.fullName
        self.full_name = r.fullName
        self.avatar_url = APIURL(rawValue: r.avatarURL)
        self.pronouns = r.pronouns
    }

    public init(user: User) {
        self.id = ID(user.id)
        self.name = user.name
        self.full_name = user.name
        self.avatar_url = APIURL(rawValue: user.avatarURL)
        self.pronouns = user.pronouns
    }
}

extension Array where Element == APIConversationRecipient {
    public func sortedByName() -> [APIConversationRecipient] {
        return self.sorted(by: { $0.name < $1.name })
    }
}

#if DEBUG
extension APIConversationRecipient {
    public static func make(
        id: ID = "1",
        name: String = "Homestar",
        full_name: String = "Homestar Runner",
        avatar_url: APIURL? = .make(rawValue: URL(string: "https://homestarrunner.com/tempHomeImg/logo_200x200@2x.png")!),
        pronouns: String? = nil
    ) -> APIConversationRecipient {
        return APIConversationRecipient(
            id: id,
            name: name,
            full_name: full_name,
            avatar_url: avatar_url,
            pronouns: pronouns
        )
    }
}
#endif

public struct GetConversationRecipientsRequest: APIRequestable {
    public typealias Response = [APIConversationRecipient]

    public init(search: String, context: String? = nil, includeContexts: Bool = false) {
        var items: [APIQueryItem] = [
            .value("per_page", "10"),
            .value("search", search),
            .value("synthetic_contexts", "1"),
        ]
        if let context = context {
            items.append(.value("context", context))
        }
        if !includeContexts {
            items.append(.value("type", "user"))
        }
        query = items
    }

    public let path = "search/recipients"
    public let query: [APIQueryItem]
}
