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

struct AnnouncementItem: Identifiable, Equatable {
    static let publicPreview: [Self] = [
        .init(
            title: String(localized: "Finals are moving to next week.", comment: "Example announcement title"),
            date: Date(),
            url: URL(string: "https://www.instructure.com/")!,
            authorName: String(localized: "Thomas McKempis", comment: "Example author name"),
            courseName: String(localized: "Introduction to the Solar System", comment: "Example course name"),
            courseColor: .textInfo),
        .init(
            title: String(localized: "Zoo Field Trip!", comment: "Example announcement title"),
            date: Date().addDays(-1),
            url: URL(string: "https://www.instructure.com/")!,
            authorName: String(localized: "Susan Jorgenson", comment: "Example author name"),
            courseName: String(localized: "Biology 201", comment: "Example course name"),
            courseColor: .course3),
        .init(
            title: String(localized: "Read Moby Dick by end of week.", comment: "Example announcement title"),
            date: Date().addDays(-5),
            url: URL(string: "https://www.instructure.com/")!,
            authorName: String(localized: "Janet Hammond", comment: "Example author name"),
            courseName: String(localized: "American literature IV", comment: "Example course name"),
            courseColor: .textSuccess)
        ]

    let id: String
    let title: String
    let date: Date
    let url: URL

    let authorName: String
    let avatar: UIImage?

    let courseName: String
    let courseColor: Color

    init(dbEntity: CDWidgetAnnouncement) {
        self.id = dbEntity.id
        self.title = dbEntity.title
        self.date = dbEntity.date
        self.url = dbEntity.url
        self.authorName = dbEntity.authorName
        self.courseName = dbEntity.courseName
        self.courseColor = Color(dbEntity.courseColor)
        self.avatar = dbEntity.avatar
    }

    init(
        title: String,
        date: Date,
        url: URL,
        authorName: String,
        courseName: String,
        courseColor: Color
    ) {
        self.id = UUID().uuidString
        self.title = title
        self.date = date
        self.url = url
        self.authorName = authorName
        self.courseName = courseName
        self.courseColor = courseColor
        self.avatar = nil
    }
}
