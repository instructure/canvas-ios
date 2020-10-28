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

import Core

struct AnnouncementItem: Identifiable {
    let id: String

    let message: String?
    let title: String
    let date: Date
    let authorName: String
    let avatarURL: URL?

    init?(_ discussionTopic: DiscussionTopic) {
        print(discussionTopic)
        guard
            discussionTopic.isAnnouncement,
            let title = discussionTopic.title,
            let date = discussionTopic.postedAt,
            let author = discussionTopic.author
        else { return nil }

        self.id = discussionTopic.id
        self.title = title
        self.message = discussionTopic.message
        self.date = date
        self.authorName = author.displayName
        self.avatarURL = author.avatarURL
    }

#if DEBUG
    init(title: String) {
        self.id = "1"
        self.message = "Test"
        self.title = title
        self.date = Date()
        self.authorName = "Professor Snape"
        self.avatarURL = nil
    }
#endif
}
