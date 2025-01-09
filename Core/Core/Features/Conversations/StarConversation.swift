//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

public class StarConversation: APIUseCase {
    public var cacheKey: String?
    public typealias Model = Conversation
    public let id: String
    public let starred: Bool

    public var scope: Scope {
        Scope.where(#keyPath(InboxMessageListItem.messageId), equals: id)
    }

    public var request: StarConversationRequest {
        return StarConversationRequest(id: id, starred: starred)
    }

    public init(id: String, starred: Bool) {
        self.id = id
        self.starred = starred
    }

    public func write(response: APIConversation?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response else {
            return
        }

        Conversation.save(response, in: client)
        let entities: [InboxMessageListItem] = client.fetch(scope: scope)

        entities
            .compactMap { InboxMessageScope(rawValue: $0.scopeFilter) }
            .forEach { scope in
                InboxMessageListItem.save(
                    response,
                    currentUserID: AppEnvironment.shared.currentSession?.userID ?? "",
                    isSent: scope == .sent,
                    contextFilter: .none,
                    scopeFilter: scope,
                    in: client
                )
        }
    }
}
