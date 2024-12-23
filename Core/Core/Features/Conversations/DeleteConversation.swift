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

public class DeleteConversation: APIUseCase {
    public var cacheKey: String?
    public typealias Model = Conversation
    public let id: String

    public var scope: Scope {
        Scope.where(#keyPath(InboxMessageListItem.messageId), equals: id)
    }
    private let inboxMessageScope: InboxMessageScope

    public var request: DeleteConversationRequest {
        return DeleteConversationRequest(id: id)
    }

    public init(id: String, inboxScopeFilter: InboxMessageScope = .sent) {
        self.id = id
        self.inboxMessageScope = inboxScopeFilter
    }

    public func write(response: APIConversation?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        let entities: [InboxMessageListItem] = client.fetch(scope: scope)
        entities.forEach { message in
            client.delete(message)
            try? client.save()
        }
    }
}

public class DeleteConversationMessage: APIUseCase {
    public var cacheKey: String?
    public typealias Model = Conversation
    public let id: String
    public let removeIds: [String]

    public var request: DeleteConversationMessageRequest {
        return DeleteConversationMessageRequest(id: id, body: .init(remove: removeIds))
    }

    public init(id: String, removeIds: [String]) {
        self.id = id
        self.removeIds = removeIds
    }
}
