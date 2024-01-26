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

public struct ComposeMessageOptions {
    var disabledFields: DisabledMessageFieldOptions
    var fieldContents: DefaultMessageFieldContents

    public init(disabledFields: DisabledMessageFieldOptions = DisabledMessageFieldOptions(), fieldsContents: DefaultMessageFieldContents = DefaultMessageFieldContents()) {
        self.disabledFields = disabledFields
        self.fieldContents = fieldsContents
    }
}

extension ComposeMessageOptions {

    public enum MessageType {
        case new, reply(conversation: Conversation, author: String? = nil), forward(conversation: Conversation, message: ConversationMessage?)
    }

    public init(fromType type: MessageType) {
        switch type {
        case .new:
            self.init()
        case .forward(let conversation, let message):
            self.init(conversation: conversation, message: message)
        case .reply(let conversation, let author):
            self.init(conversation: conversation, author: author)
        }
    }

    private init() {
        self.disabledFields = DisabledMessageFieldOptions()
        self.fieldContents = DefaultMessageFieldContents()
    }

    private init(conversation: Conversation, message: ConversationMessage?) {
        let disabledOptions = DisabledMessageFieldOptions(
            contextDisabled: true,
            recipientsDisabled: false,
            subjectDisabled: true,
            messageDisabled: true,
            individualDisabled: true
        )
        var fieldContents = DefaultMessageFieldContents()

        fieldContents.subjectText = "Fw: \(conversation.subject)"
        fieldContents.bodyText = "Forwarded Message:\n\(message?.body ?? "")"

        if let context = Context(canvasContextID: conversation.contextCode ?? "") {
            fieldContents.selectedContext = .init(name: conversation.contextName ?? "", context: context)
        }

        self.disabledFields = disabledOptions
        self.fieldContents = fieldContents
    }

    private init(conversation: Conversation, author: String? = nil) {
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
        if let author {
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
    }
}
