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

public class CreateConversation: APIUseCase {
    public typealias Model = Conversation

    let subject: String
    let body: String
    let recipientIDs: [String]
    let mediaCommentID: String?
    let mediaCommentType: MediaCommentType?
    let attachmentIDs: [String]?
    let bulkMessage: Bool
    let canvasContextID: String?

    public init(
        subject: String,
        body: String,
        recipientIDs: [String],
        canvasContextID: String? = nil,
        mediaCommentID: String? = nil,
        mediaCommentType: MediaCommentType? = nil,
        attachmentIDs: [String]? = nil,
        bulkMessage: Bool = false
    ) {
        self.subject = subject
        self.body = body
        self.recipientIDs = recipientIDs
        self.canvasContextID = canvasContextID
        self.mediaCommentID = mediaCommentID
        self.mediaCommentType = mediaCommentType
        self.attachmentIDs = attachmentIDs
        self.bulkMessage = bulkMessage
    }

    public let cacheKey: String? = nil

    public var request: PostConversationRequest {
        PostConversationRequest(body: PostConversationRequest.Body(
            subject: subject,
            body: body,
            recipients: recipientIDs,
            context_code: canvasContextID,
            media_comment_id: mediaCommentID,
            media_comment_type: mediaCommentType,
            attachment_ids: attachmentIDs,
            group_conversation: true, /// `group_conversation` is always true
            bulk_message: bulkMessage
        ))
    }

    public var scope: Scope = Scope.all(orderBy: #keyPath(Conversation.lastMessageAt))

    public func write(response: [APIConversation]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response else {
            return
        }

        for conversation in response {
            let conversationResponse = Conversation.save(conversation, in: client)
            // attach the context name since it is not part of the api response
            // a ticket has been created to include the context_name in the api response
            // https://instructure.atlassian.net/browse/KNO-239
            guard conversationResponse.contextName == nil,
                  let canvasContextID = canvasContextID,
                  let context = Context(canvasContextID: canvasContextID),
                  let course: Course = client.fetch(scope: .where("id", equals: context.id)).first
            else {
                continue
            }
            conversationResponse.contextName = course.name

            InboxMessageListItem.save(
                conversation,
                currentUserID: AppEnvironment.shared.currentSession?.userID ?? "",
                isSent: true,
                contextFilter: .none,
                scopeFilter: .sent,
                in: client
            )

            InboxMessageListItem.save(
                conversation,
                currentUserID: AppEnvironment.shared.currentSession?.userID ?? "",
                isSent: true,
                contextFilter: Context(canvasContextID: conversation.context_code ?? ""),
                scopeFilter: .sent,
                in: client
            )
        }
    }
}
