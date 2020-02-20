//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

public class AddMessage: APIUseCase {
    public typealias Model = Conversation

    let conversationID: String

    let attachmentIDs: [String]?
    let body: String
    let mediaCommentID: String?
    let mediaCommentType: MediaCommentType?
    let recipientIDs: [String]?

    public init(
        conversationID: String,
        attachmentIDs: [String]? = nil,
        body: String,
        mediaCommentID: String? = nil,
        mediaCommentType: MediaCommentType? = nil,
        recipientIDs: [String]? = nil
    ) {
        self.conversationID = conversationID
        self.attachmentIDs = attachmentIDs
        self.body = body
        self.mediaCommentID = mediaCommentID
        self.mediaCommentType = mediaCommentType
        self.recipientIDs = recipientIDs
    }

    public let cacheKey: String? = nil

    public var request: PostAddMessageRequest {
        PostAddMessageRequest(conversationID: conversationID, body: PostAddMessageRequest.Body(
            attachment_ids: attachmentIDs,
            body: body,
            media_comment_id: mediaCommentID,
            media_comment_type: mediaCommentType,
            recipients: recipientIDs
        ))
    }

    public var scope: Scope {
        Scope.where(#keyPath(Conversation.id), equals: conversationID)
    }

    public func write(response: APIConversation?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard
            let item = response,
            let model: Conversation = client.fetch(scope: scope).first
        else { return }

        model.audienceIDs = item.audience?.map { $0.value } ?? []
        model.lastMessage = item.last_message ?? item.last_authored_message ?? ""
        model.lastMessageAt = item.last_message_at ?? item.last_authored_message_at ?? Date()
        model.messageCount = item.message_count

        model.participants = Set(item.participants.map {
            ConversationParticipant.save($0, in: client)
        })

        if let messages = item.messages, !messages.isEmpty {
            model.messages = messages.map {
                ConversationMessage.save($0, in: client)
            } + model.messages
        }

        model.workflowState = item.workflow_state
    }
}
