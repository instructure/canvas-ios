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

import SwiftUI

public struct MessageViewModel: Identifiable, Equatable {
    public let id: String
    public let body: String
    public let author: String
    public let date: String
    public let avatarName: String
    public let avatarURL: URL?
    public let attachments: [File]
    public let mediaComment: MediaComment?
    public let showAttachments: Bool

    public init(item: ConversationMessage, myID: String, userMap: [String: ConversationParticipant]) {
        self.id = item.id
        self.body = item.body

        let from = userMap[ item.authorID ]?.displayName ?? ""
        let to = item.localizedAudience(myID: myID, userMap: userMap)
        self.author = from + " " + to

        self.date = item.createdAt?.relativeDateTimeString ?? ""
        self.avatarURL = userMap[ item.authorID ]?.avatarURL
        self.avatarName = userMap[ item.authorID ]?.name ?? ""

        self.attachments = item.attachments
        self.mediaComment = item.mediaComment
        self.showAttachments = !attachments.isEmpty || mediaComment != nil
    }
}
