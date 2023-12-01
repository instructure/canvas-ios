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

    let displayName: String
    let avatarURL: URL?
    let ids: [String]

    init(id: String, name: String, avatarURL: URL?) {
        self.ids = [id]
        self.displayName = name
        self.avatarURL = avatarURL
    }

    init(ids: [String], name: String, avatarURL: URL?) {
        self.ids = ids
        self.displayName = name
        self.avatarURL = avatarURL
    }

    init(searchRecipient: SearchRecipient) {
        self.ids = [searchRecipient.id]
        self.displayName = searchRecipient.name
        self.avatarURL = searchRecipient.avatarURL
    }

    init(searchRecipients: [SearchRecipient], displayName: String, avatarURL: URL? = nil) {
        self.ids = searchRecipients.map { $0.id }
        self.displayName = displayName
        self.avatarURL = avatarURL
    }

    init(conversationParticipant: ConversationParticipant) {
        self.ids = [conversationParticipant.id]
        self.displayName = conversationParticipant.name
        self.avatarURL = conversationParticipant.avatarURL
    }

    init(conversationParticipants: [ConversationParticipant], displayName: String, avatarURL: URL? = nil) {
        self.ids = conversationParticipants.map { $0.id }
        self.displayName = displayName
        self.avatarURL = avatarURL
    }

}
