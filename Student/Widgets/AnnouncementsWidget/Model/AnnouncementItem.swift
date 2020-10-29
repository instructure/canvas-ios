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
import SwiftUI
import WidgetKit

struct AnnouncementItem: Identifiable {
    let id: String
    let title: String
    let date: Date
    let url: URL

    let authorName: String
    let avatarURL: URL?

    let courseName: String
    let courseColor: Color

    init?(discussionTopic: DiscussionTopic, course: Course) {
        guard
            discussionTopic.isAnnouncement,
            let title = discussionTopic.title,
            let date = discussionTopic.postedAt,
            let author = discussionTopic.author,
            let courseName = course.name,
            let url = discussionTopic.htmlURL
        else { return nil }

        self.id = discussionTopic.id
        self.title = title
        self.date = date
        self.url = url
        self.authorName = author.displayName
        self.avatarURL = author.avatarURL
        self.courseName = courseName
        self.courseColor = Color(course.color)
    }

    init(title: String, date: Date, url: URL, authorName: String, avatarURL: URL? = nil, courseName: String, courseColor: Color) {
        self.id = UUID().uuidString
        self.title = title
        self.date = date
        self.url = url
        self.authorName = authorName
        self.avatarURL = avatarURL
        self.courseName = courseName
        self.courseColor = courseColor
    }
}
