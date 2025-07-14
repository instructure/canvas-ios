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

import WidgetKit

struct AnnouncementsEntry: TimelineEntry {
    static let publicPreview: Self = .init(announcements: .publicPreviewItems)
    static let loggedOutModel: Self = .init(isLoggedIn: false)

    let announcements: [AnnouncementItem]
    let isLoggedIn: Bool
    let date: Date

    init(announcements: [AnnouncementItem] = [], isLoggedIn: Bool = true, date: Date = .now) {
        self.announcements = announcements
        self.isLoggedIn = isLoggedIn
        self.date = date
    }
}

#if DEBUG
extension AnnouncementsEntry {
    public static func make() -> AnnouncementsEntry {
        let url = URL(string: "https://www.instructure.com/")!

        return AnnouncementsEntry(
            announcements: [
                AnnouncementItem(
                    title: "Finals are moving to next week.",
                    date: Date(),
                    url: url,
                    authorName: "Thomas McKempis",
                    courseName: "Introduction to the Solar System",
                    courseColor: .textInfo),
                AnnouncementItem(
                    title: "Zoo Field Trip!",
                    date: Date().addDays(-1),
                    url: url,
                    authorName: "Susan Jorgenson",
                    courseName: "Biology 201",
                    courseColor: .course3),
                AnnouncementItem(
                    title: "Read Moby Dick by end of week.",
                    date: Date().addDays(-5),
                    url: url,
                    authorName: "Janet Hammond",
                    courseName: "American literature IV",
                    courseColor: .textSuccess),
                AnnouncementItem(
                    title: "Zoo Field Trip!",
                    date: Date().addDays(-1),
                    url: url,
                    authorName: "Susan Jorgenson",
                    courseName: "Biology 201",
                    courseColor: .course3),
                AnnouncementItem(
                    title: "Read Moby Dick by end of week.",
                    date: Date().addDays(-5),
                    url: url,
                    authorName: "Janet Hammond",
                    courseName: "American literature IV",
                    courseColor: .textSuccess)
            ]
        )
    }
}
#endif
