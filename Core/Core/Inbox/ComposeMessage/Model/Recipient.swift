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

public struct Recipient: Equatable, Hashable {

    public let displayName: String
    public let avatarURL: URL?
    public let ids: [String]

    public init(id: String, name: String, avatarURL: URL?) {
        self.ids = [id]
        self.displayName = name
        self.avatarURL = avatarURL
    }

    public init(ids: [String], name: String, avatarURL: URL?) {
        self.ids = ids
        self.displayName = name
        self.avatarURL = avatarURL
    }

    public init(searchRecipient: SearchRecipient) {
        self.ids = [searchRecipient.id]
        self.displayName = searchRecipient.displayName ?? searchRecipient.name
        self.avatarURL = searchRecipient.avatarURL
    }

    public init(searchRecipients: [SearchRecipient], displayName: String, avatarURL: URL? = nil) {
        self.ids = searchRecipients.map { $0.id }
        self.displayName = displayName
        self.avatarURL = avatarURL
    }

    public init(conversationParticipant: ConversationParticipant) {
        self.ids = [conversationParticipant.id]
        self.displayName = conversationParticipant.displayName
        self.avatarURL = conversationParticipant.avatarURL
    }

    public init(conversationParticipants: [ConversationParticipant], displayName: String, avatarURL: URL? = nil) {
        self.ids = conversationParticipants.map { $0.id }
        self.displayName = displayName
        self.avatarURL = avatarURL
    }

}
