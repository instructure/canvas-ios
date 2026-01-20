//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import Core

struct HInboxMessageModel: Identifiable, Equatable {
    let attachments: [AttachmentFileModel]
    let author: String
    let body: String
    let date: String
    let id: String
    let isAnnouncement: Bool

    var accessibilityLabel: String {
        var parts: [String] = []
        parts.append(String(format: String(localized: "Sender %@"), author))
        parts.append(String(format: String(localized: "Body %@"), body))
        parts.append(String(format: String(localized: "Date %@"), date))
        return parts.joined(separator: ", ")
    }
}

extension HInboxMessageModel {
    init(
        conversationMessage: ConversationMessage,
        router: Router,
        userID: String,
        userMap: [String: ConversationParticipant]
    ) {
        self.id = conversationMessage.id
        self.body = conversationMessage.body
        self.isAnnouncement = false
        self.author = conversationMessage.authorID == userID ?
            String(localized: "You", bundle: .horizon) :
            (userMap[conversationMessage.authorID]?.name ?? conversationMessage.authorID)

        self.date = conversationMessage.createdAt?.dateTimeString ?? ""
        self.attachments = conversationMessage.attachments.map { .init(file: $0)}
    }
}

extension Array where Element == ConversationMessage {
    func toHInboxMessageModels(
        router: Router,
        userID: String,
        userMap: [String: ConversationParticipant]
    ) -> [HInboxMessageModel] {
        self.map { message in
            HInboxMessageModel(
                conversationMessage: message,
                router: router,
                userID: userID,
                userMap: userMap
            )
        }
    }
}
