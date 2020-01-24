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

public struct APISearchRecipientsRequestable: APIRequestable {
    public typealias Response = [APISearchRecipient]

    public enum ContextQualifier: String {
        case teachers, students, observers, tas
    }

    let context: Context
    let contextQualifier: ContextQualifier?
    let search: String
    let perPage: Int?
    let skipVisibilityChecks: Int?
    let syntheticContexts: Int?
    let userID: String?

    public init(context: Context, contextQualifier: ContextQualifier? = nil, search: String = "",
                userID: String? = nil, perPage: Int? = 50, skipVisibilityChecks: Int? = nil, syntheticContexts: Int? = nil) {
        self.context = context
        self.contextQualifier = contextQualifier
        self.search = search
        self.perPage = perPage
        self.skipVisibilityChecks = skipVisibilityChecks
        self.syntheticContexts = syntheticContexts
        self.userID = userID
    }

    public var path = "search/recipients"

    public var query: [APIQueryItem] {
        var contextStr = context.canvasContextID
        if let qualifier = contextQualifier { contextStr.append("_\(qualifier.rawValue)") }
        let contextQueryItem = APIQueryItem.value("context", contextStr)

        var queryItems = [
            contextQueryItem,
            APIQueryItem.value("search", search),
        ]

        if let userID = userID {
            queryItems.append(.value("user_id", "\(userID)"))
        }

        if let perPage = perPage {
            queryItems.append(.value("per_page", "\(perPage)"))
        }
        if let skip = skipVisibilityChecks {
            queryItems.append(.value("skip_visibility_checks", "\(skip)"))
        }
        if let synthetic = syntheticContexts {
            queryItems.append(.value("synthetic_contexts", "\(synthetic)"))
        }
        return queryItems
    }
}
