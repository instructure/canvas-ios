//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public struct MessageParameters {

    public let subject: String
    public let body: String
    public let recipientIDs: [String]
    public let attachmentIDs: [String]
    public let context: Context
    public let conversationID: String?
    public let groupConversation: Bool
    public let includedMessages: [String]?
    public let bulkMessage: Bool

    public init(
        subject: String,
        body: String,
        recipientIDs: [String],
        attachmentIDs: [String] = [],
        context: Context,
        conversationID: String? = nil,
        groupConversation: Bool = true,
        bulkMessage: Bool,
        includedMessages: [String]? = nil
    ) {
        self.subject = subject
        self.body = body
        self.recipientIDs = recipientIDs
        self.attachmentIDs = attachmentIDs
        self.context = context
        self.conversationID = conversationID
        self.groupConversation = groupConversation
        self.bulkMessage = bulkMessage
        self.includedMessages = includedMessages
    }
}
