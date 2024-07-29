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
    var individualSend: Bool

    public init(selectedContext: RecipientContext? = nil, selectedRecipients: [Recipient] = [], subjectText: String = "", bodyText: String = "", individualSend: Bool = false) {
        self.selectedContext = selectedContext
        self.selectedRecipients = selectedRecipients
        self.subjectText = subjectText
        self.bodyText = bodyText
        self.individualSend = individualSend
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

public struct ExtraMessageOptions {
    var hiddenMessage: String
    var autoTeacherSelect: Bool
    var alwaysShowRecipients: Bool
    var teacherOnly: Bool

    public init(hiddenMessage: String = "", autoTeacherSelect: Bool = false, alwaysShowRecipients: Bool = false, teacherOnly: Bool = false) {
        self.hiddenMessage = hiddenMessage
        self.autoTeacherSelect = autoTeacherSelect
        self.alwaysShowRecipients = alwaysShowRecipients
        self.teacherOnly = teacherOnly
    }
}

public class ComposeMessageOptions {
    var disabledFields: DisabledMessageFieldOptions
    var fieldContents: DefaultMessageFieldContents
    var messageType: MessageType
    var extras: ExtraMessageOptions

    public init(
        disabledFields: DisabledMessageFieldOptions = DisabledMessageFieldOptions(),
        fieldsContents: DefaultMessageFieldContents = DefaultMessageFieldContents(),
        messageType: MessageType = .new,
        extras: ExtraMessageOptions = .init()
    ) {
        self.disabledFields = disabledFields
        self.fieldContents = fieldsContents
        self.messageType = messageType
        self.extras = extras
    }

    public init(queryItems: [URLQueryItem]) {
        var disabledFields = DisabledMessageFieldOptions()
        var fieldContents = DefaultMessageFieldContents()
        var extras = ExtraMessageOptions()
        let messageType = MessageType.new

        var contextCode: String?
        var contextName: String?
        var recipientIds: [String] = []
        var recipientNames: [String] = []
        var recipientAvatars: [String] = []

        queryItems.forEach { queryItem in
            guard let queryParameter = ComposeMessageOptions.QueryParameterKey(rawValue: queryItem.name) else { return }
            switch queryParameter {
            case .contextDisabled:
                disabledFields.contextDisabled = queryItem.value?.boolValue ?? false
            case .recipientsDisabled:
                disabledFields.recipientsDisabled = queryItem.value?.boolValue ?? false
            case .subjectDisabled:
                disabledFields.subjectDisabled = queryItem.value?.boolValue ?? false
            case .messageDisabled:
                disabledFields.messageDisabled = queryItem.value?.boolValue ?? false
            case .individualDisabled:
                disabledFields.individualDisabled = queryItem.value?.boolValue ?? false
            case .contextCodeContent:
                contextCode = queryItem.value?.removingPercentEncoding
            case .contextNameContent:
                contextName = queryItem.value?.removingPercentEncoding
            case .recipientIdsContent:
                recipientIds = queryItem.value?.removingPercentEncoding?.split(separator: ",").map { String($0) } ?? []
            case .recipientNamesContent:
                recipientNames = queryItem.value?.removingPercentEncoding?.split(separator: ",").map { String($0) } ?? []
            case .recipientAvatarsContent:
                recipientAvatars = queryItem.value?.removingPercentEncoding?.split(separator: ",", omittingEmptySubsequences: false).map { String($0) } ?? []
            case .subjectContent:
                fieldContents.subjectText = queryItem.value?.removingPercentEncoding ?? ""
            case .messageContent:
                fieldContents.bodyText = queryItem.value?.removingPercentEncoding ?? ""
            case .individualSendText:
                fieldContents.individualSend = queryItem.value?.boolValue ?? false
            case .hiddenMessage:
                extras.hiddenMessage = queryItem.value?.removingPercentEncoding ?? ""
            case .autoTeacherSelect:
                extras.autoTeacherSelect = queryItem.value?.boolValue ?? false
            case .alwaysShowRecipients:
                extras.alwaysShowRecipients = queryItem.value?.boolValue ?? false
            case .teacherOnly:
                extras.teacherOnly = queryItem.value?.boolValue ?? false
            }
        }

        if let contextCode, let contextName, let context = Context(canvasContextID: contextCode) {
            fieldContents.selectedContext = RecipientContext(name: contextName, context: context)
        }

        if recipientIds.count == recipientNames.count && recipientIds.count == recipientAvatars.count {
            for (id, (name, avatar)) in zip(recipientIds, zip(recipientNames, recipientAvatars)) {
                fieldContents.selectedRecipients.append(.init(id: id, name: name, avatarURL: URL(string: avatar)))
            }
        } else if recipientIds.count == recipientNames.count {
            for (id, name) in zip(recipientIds, recipientNames) {
                fieldContents.selectedRecipients.append(.init(id: id, name: name, avatarURL: nil))
            }
        }

        self.disabledFields = disabledFields
        self.fieldContents = fieldContents
        self.messageType = messageType
        self.extras = extras
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
        if let author = message?.authorID, let participantIDs = message?.participantIDs {
            recipients = conversation.audience.filter { $0.id == author }.map { Recipient(conversationParticipant: $0) }

            if recipients.isEmpty {
                let recipientsSet = Set(participantIDs).subtracting(Set([author]))

                for r in recipientsSet {
                    recipients.append(contentsOf: conversation.audience
                        .filter { $0.id == r }
                        .map { Recipient(conversationParticipant: $0) }
                    )
                }
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

extension ComposeMessageOptions {

    enum QueryParameterKey: String, CaseIterable {
        // MARK: Disabled fields
        case contextDisabled
        case recipientsDisabled
        case subjectDisabled
        case messageDisabled
        case individualDisabled

        // MARK: Field contents
        case contextCodeContent
        case contextNameContent
        case recipientIdsContent
        case recipientNamesContent
        case recipientAvatarsContent
        case subjectContent
        case messageContent
        case individualSendText

        // MARK: Extras
        case hiddenMessage
        case autoTeacherSelect
        case alwaysShowRecipients
        case teacherOnly
    }

    public var queryItems: [URLQueryItem] {
        var queryItems: [URLQueryItem] = []

        // MARK: Disabled fields
        queryItems.append(.init(key: .contextDisabled, value: String(disabledFields.contextDisabled)))
        queryItems.append(.init(key: .contextDisabled, value: String(disabledFields.contextDisabled)))
        queryItems.append(.init(key: .recipientsDisabled, value: String(disabledFields.recipientsDisabled)))
        queryItems.append(.init(key: .subjectDisabled, value: String(disabledFields.subjectDisabled)))
        queryItems.append(.init(key: .messageDisabled, value: String(disabledFields.messageDisabled)))
        queryItems.append(.init(key: .individualDisabled, value: String(disabledFields.individualDisabled)))

        // MARK: Field contents
        if let selectedContext = fieldContents.selectedContext {
            queryItems.append(.init(key: .contextCodeContent, value: selectedContext.context.canvasContextID.urlSafePercentEncoded))
            queryItems.append(.init(key: .contextNameContent, value: selectedContext.name.urlSafePercentEncoded))
        }
        queryItems.append(
            .init(key: .recipientIdsContent, value: fieldContents.selectedRecipients.flatMap { $0.ids }.joined(separator: ",").urlSafePercentEncoded)
        )
        queryItems.append(
            .init(key: .recipientNamesContent, value: fieldContents.selectedRecipients.map { $0.displayName }.joined(separator: ",").urlSafePercentEncoded)
        )
        queryItems.append(
            .init(key: .recipientAvatarsContent, value: fieldContents.selectedRecipients.map { $0.avatarURL?.absoluteString ?? "" }.joined(separator: ",").urlSafePercentEncoded)
        )
        queryItems.append(.init(key: .subjectContent, value: fieldContents.subjectText.urlSafePercentEncoded))
        queryItems.append(.init(key: .messageContent, value: fieldContents.bodyText.urlSafePercentEncoded))
        queryItems.append(.init(key: .individualDisabled, value: String(fieldContents.individualSend).urlSafePercentEncoded))

        // MARK: Extras
        queryItems.append(.init(key: .hiddenMessage, value: extras.hiddenMessage.urlSafePercentEncoded))
        queryItems.append(.init(key: .autoTeacherSelect, value: String(extras.autoTeacherSelect)))
        queryItems.append(.init(key: .alwaysShowRecipients, value: String(extras.alwaysShowRecipients)))
        queryItems.append(.init(key: .teacherOnly, value: String(extras.teacherOnly)))

        return queryItems
    }
}

private extension URLQueryItem {
    init(key: ComposeMessageOptions.QueryParameterKey, value: String?) {
        self.init(name: key.rawValue, value: value)
    }
}
