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

public struct DefaultMessageFieldContents {
    var selectedContext: RecipientContext?
    var selectedRecipients: [Recipient]
    var subjectText: String
    var bodyText: String

    public init(selectedContext: RecipientContext? = nil, selectedRecipients: [Recipient] = [], subjectText: String = "", bodyText: String = "") {
        self.selectedContext = selectedContext
        self.selectedRecipients = selectedRecipients
        self.subjectText = subjectText
        self.bodyText = bodyText
    }
}

public struct DisabledMessageFieldOptions {
    var contextDisabled: Bool
    var recipientsDisabled: Bool
    var subjectDisabled: Bool
    var messageDisabled: Bool
    var individualDisabled: Bool

    public init(contextDisabled: Bool = false, recipientsDisabled: Bool = false, subjectDisabled: Bool = false, messageDisabled: Bool = false, individualDisabled: Bool = false) {
        self.contextDisabled = contextDisabled
        self.recipientsDisabled = recipientsDisabled
        self.subjectDisabled = subjectDisabled
        self.messageDisabled = messageDisabled
        self.individualDisabled = individualDisabled
    }
}

public class ComposeMessageOptions {
    var disabledFields: DisabledMessageFieldOptions
    var fieldContents: DefaultMessageFieldContents
    var messageType: MessageType

    public init(
        disabledFields: DisabledMessageFieldOptions = DisabledMessageFieldOptions(),
        fieldsContents: DefaultMessageFieldContents = DefaultMessageFieldContents(),
        messageType: MessageType = .new
    ) {
        self.disabledFields = disabledFields
        self.fieldContents = fieldsContents
        self.messageType = messageType
    }
}

extension ComposeMessageOptions {

    public enum MessageType: Equatable {
        case new,
             reply(conversation: Conversation, message: ConversationMessage? = nil),
             replyAll(conversation: Conversation, message: ConversationMessage? = nil),
             forward(conversation: Conversation, message: ConversationMessage?)
    }

    public convenience init(fromType type: MessageType) {
        self.init()

        switch type {
        case .new:
            self.initForNew()
        case .forward(let conversation, let message):
            self.initForForward(conversation: conversation, message: message)
        case .reply(let conversation, let message):
            self.initForReply(conversation: conversation, message: message)
        case .replyAll(let conversation, let message):
            self.initForReplyAll(conversation: conversation, message: message)
        }
    }

    private func initForNew() {
        self.disabledFields = DisabledMessageFieldOptions()
        self.fieldContents = DefaultMessageFieldContents()
        self.messageType = .new
    }

    private func initForForward(conversation: Conversation, message: ConversationMessage?) {
        let disabledOptions = DisabledMessageFieldOptions(
            contextDisabled: true,
            recipientsDisabled: false,
            subjectDisabled: true,
            messageDisabled: false,
            individualDisabled: true
        )
        var fieldContents = DefaultMessageFieldContents()

        fieldContents.subjectText = String(localized: "Fw: \(conversation.subject)", bundle: .core, comment: "New conversation subject for forwarded message")

        if let context = Context(canvasContextID: conversation.contextCode ?? "") {
            fieldContents.selectedContext = .init(name: conversation.contextName ?? "", context: context)
        }

        self.disabledFields = disabledOptions
        self.fieldContents = fieldContents
        self.messageType = .forward(conversation: conversation, message: message)
    }

    private func initForReply(conversation: Conversation, message: ConversationMessage? = nil) {
        let disabledOptions = DisabledMessageFieldOptions(
            contextDisabled: true,
            recipientsDisabled: false,
            subjectDisabled: true,
            messageDisabled: false,
            individualDisabled: true
        )
        var fieldContents = DefaultMessageFieldContents()

        fieldContents.subjectText = conversation.subject

        if let context = Context(canvasContextID: conversation.contextCode ?? "") {
            fieldContents.selectedContext = .init(name: conversation.contextName ?? "", context: context)
        }

        var recipients = [Recipient]()
        if let author = message?.authorID {
            recipients = conversation.audience.filter { $0.id == author }.map { Recipient(conversationParticipant: $0) }

            if recipients.isEmpty {
                recipients = conversation.audience.map { Recipient(conversationParticipant: $0) }
            }
        } else {
            recipients = conversation.audience.map { Recipient(conversationParticipant: $0) }
        }
        fieldContents.selectedRecipients = recipients

        self.disabledFields = disabledOptions
        self.fieldContents = fieldContents
        self.messageType = .reply(conversation: conversation, message: message)
    }

    private func initForReplyAll(conversation: Conversation, message: ConversationMessage? = nil) {
        let disabledOptions = DisabledMessageFieldOptions(
            contextDisabled: true,
            recipientsDisabled: false,
            subjectDisabled: true,
            messageDisabled: false,
            individualDisabled: true
        )
        var fieldContents = DefaultMessageFieldContents()

        fieldContents.subjectText = conversation.subject

        if let context = Context(canvasContextID: conversation.contextCode ?? "") {
            fieldContents.selectedContext = .init(name: conversation.contextName ?? "", context: context)
        }

        let recipients = conversation.audience.map { Recipient(conversationParticipant: $0) }
        fieldContents.selectedRecipients = recipients

        self.disabledFields = disabledOptions
        self.fieldContents = fieldContents
        self.messageType = .replyAll(conversation: conversation, message: message)
    }
}
