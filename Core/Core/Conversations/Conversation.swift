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
import CoreData

final public class Conversation: NSManagedObject, WriteableModel {
    @NSManaged var audienceIDsRaw: String
    @NSManaged public var avatarURL: URL?
    @NSManaged public var contextCode: String?
    @NSManaged public var contextName: String?
    @NSManaged public var id: String
    @NSManaged public var lastMessage: String
    @NSManaged public var lastMessageAt: Date?
    @NSManaged public var messageCount: Int
    @NSManaged var messagesRaw: NSOrderedSet?
    @NSManaged public var participants: Set<ConversationParticipant>
    @NSManaged public var starred: Bool
    @NSManaged public var subject: String
    @NSManaged var workflowStateRaw: String
    @NSManaged public var cannotReply: Bool

    public var audience: [ConversationParticipant] {
        return audienceIDs.compactMap { id in participants.first(where: { $0.id == id }) }
    }

    public var audienceIDs: [String] {
        get { audienceIDsRaw.split(separator: ",").map { String($0) } }
        set { audienceIDsRaw = newValue.joined(separator: ",") }
    }

    public var messages: [ConversationMessage] {
        get { messagesRaw?.array as? [ConversationMessage] ?? [] }
        set { messagesRaw = NSOrderedSet(array: newValue) }
    }

    public var workflowState: ConversationWorkflowState {
        get { ConversationWorkflowState(rawValue: workflowStateRaw) ?? .read }
        set { workflowStateRaw = newValue.rawValue }
    }

    @discardableResult
    public static func save(_ item: APIConversation, in context: NSManagedObjectContext) -> Conversation {
        let model: Conversation = context.first(where: #keyPath(Conversation.id), equals: item.id.value) ?? context.insert()
        model.audienceIDs = item.audience?.map { $0.value } ?? []
        model.avatarURL = item.avatar_url.rawValue
        model.contextCode = item.context_code
        model.contextName = item.context_name
        model.id = item.id.value
        model.lastMessage = item.last_message ?? item.last_authored_message ?? ""
        model.lastMessageAt = item.last_message_at ?? item.last_authored_message_at ?? Date()
        model.messageCount = item.message_count

        model.participants = Set(item.participants.map {
            ConversationParticipant.save($0, in: context)
        })

        if let messages = item.messages, !messages.isEmpty {
            model.messages = messages.map {
                ConversationMessage.save($0, in: context)
            }
        }

        model.starred = item.starred
        model.cannotReply = item.cannot_reply ?? false
        model.subject = item.subject ?? ""
        model.workflowState = item.workflow_state
        return model
    }
}
