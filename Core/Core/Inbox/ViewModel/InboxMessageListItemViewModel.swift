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

public struct InboxMessageListItemViewModel: Identifiable, Equatable {
    public let id: String
    public let participantName: String
    public let date: String
    public let title: String
    public let message: String
    public let avatar: InboxMessageAvatar
    public let isStarred: Bool
    public let state: ConversationWorkflowState
    public let isMarkAsReadActionAvailable: Bool
    public let isArchiveActionAvailable: Bool
    public let hasAttachment: Bool
    public let a11yLabel: String

    public init(message: InboxMessageListItem) {
        self.id = message.id
        self.participantName = message.participantName
        self.date = message.date
        self.title = message.title
        self.message = message.message
        self.avatar = message.avatar
        self.isStarred = message.isStarred
        self.state = message.state
        self.isMarkAsReadActionAvailable = message.isMarkAsReadActionAvailable
        self.isArchiveActionAvailable = message.isArchiveActionAvailable
        self.hasAttachment = message.hasAttachment
        self.a11yLabel = {
            String([message.title,
                    message.message,
                    message.participantName,
                    message.date,
                    message.isStarred ? String(localized: "Starred", bundle: .core) : "",
                    message.state == .unread ? String(localized: "Unread", bundle: .core) : "",
                    message.hasAttachment ? String(localized: "Attachments available", bundle: .core) : ""
                   ].joined(separator: ","))
        }()
    }
}
