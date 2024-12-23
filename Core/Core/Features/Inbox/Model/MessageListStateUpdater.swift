//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

public class MessageListStateUpdater {
    public init() {}

    public func update(message: InboxMessageListItem,
                       newState: ConversationWorkflowState) {
        guard let context = message.managedObjectContext else { return }

        let movingToArchived = (newState == .archived)
        let movingFromArchived = (message.scopeFilter == ConversationWorkflowState.archived.rawValue)

        let conversationEntities: [Conversation] = context.fetch(
            scope: Scope.where(#keyPath(Conversation.id),
                               equals: message.messageId)
        )
        conversationEntities.forEach { conversation in
            conversation.workflowState = newState
        }

        if movingToArchived || movingFromArchived {
            context.delete([message])
        } else {
            message.state = newState
        }

        try? context.save()
    }
}
