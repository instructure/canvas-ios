//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
import Foundation

struct AnnouncementModel: Equatable, RelativeDateRepresentable {
    let id: String
    let title: String
    let content: String
    var courseID: String?
    var courseName: String?
    let date: Date?
    let isRead: Bool
    let isGlobal: Bool

    init(
        id: String,
        title: String,
        content: String,
        courseID: String? = nil,
        courseName: String? = nil,
        date: Date?,
        isRead: Bool,
        isGlobal: Bool
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.courseID = courseID
        self.courseName = courseName
        self.date = date
        self.isRead = isRead
        self.isGlobal = isGlobal
    }

    init(entity: AccountNotification) {
        self.id = entity.id
        self.content = entity.message
        self.title = entity.subject
        self.date = entity.startAt
        self.isRead = entity.closed
        self.isGlobal = true
    }

    init(entity: DiscussionTopic, courses: [LearnCourse]) {
        self.id = entity.id
        self.courseID = entity.courseID
        self.title = entity.title.defaultToEmpty
        self.content = entity.message.defaultToEmpty
        self.date = entity.postedAt
        self.isRead = entity.isRead
        self.isGlobal = false
        self.courseName = courses.first(where: { $0.id ==  entity.courseID })?.name
    }

    var accessibilityCourseName: String {
        String.localizedStringWithFormat(String(localized: "Course %@", bundle: .horizon), courseName.defaultToEmpty)
    }

    var accessibilityDate: String {
        String.localizedStringWithFormat(String(localized: "Date %@", bundle: .horizon), dateFormatted)
    }

    var accessibilityTitle: String {
        String.localizedStringWithFormat(String(localized: "Title %@", bundle: .horizon), title)
    }

    static let mock: Self = .init(
        id: "1",
        title: "Title 1",
        content: "",
        date: Date(),
        isRead: false,
        isGlobal: false
    )
}
