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

public class UpdateConversationState: APIUseCase {
    public var cacheKey: String?
    public typealias Model = Conversation
    public let id: String
    public let state: ConversationWorkflowState

    public var scope: Scope {
        Scope.where(#keyPath(InboxMessageListItem.messageId), equals: id)
    }

    public var request: PutConversationRequest {
        return PutConversationRequest(id: id, workflowState: state)
    }

    public init(id: String, state: ConversationWorkflowState) {
        self.id = id
        self.state = state
    }

    public func write(response: APIConversation?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response else {
            return
        }

        let conversationEntities: [Conversation] = client.fetch(.id(response.id.value))
        conversationEntities.forEach { conversation in
            conversation.workflowState = state
            try? client.save()
        }

        let entities: [InboxMessageListItem] = client.fetch(scope: scope)
        entities.forEach { message in
            message.state = state
            try? client.save()
        }
    }
}
