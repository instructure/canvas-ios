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

import Foundation

class AnnouncementsEntry: WidgetModel {
    override class var publicPreview: AnnouncementsEntry {
        let url = URL(string: "https://www.instructure.com/")!

        return AnnouncementsEntry(announcementItems: [
            AnnouncementItem(
                title: String(localized: "Finals are moving to next week.", comment: "Example announcement title"),
                date: Date(),
                url: url,
                authorName: String(localized: "Thomas McKempis", comment: "Example author name"),
                courseName: String(localized: "Introduction to the Solar System", comment: "Example course name"),
                courseColor: .electric),
            AnnouncementItem(
                title: String(localized: "Zoo Field Trip!", comment: "Example announcement title"),
                date: Date().addDays(-1),
                url: url,
                authorName: String(localized: "Susan Jorgenson", comment: "Example author name"),
                courseName: String(localized: "Biology 201", comment: "Example course name"),
                courseColor: .course3),
            AnnouncementItem(
                title: String(localized: "Read Moby Dick by end of week.", comment: "Example announcement title"),
                date: Date().addDays(-5),
                url: url,
                authorName: String(localized: "Janet Hammond", comment: "Example author name"),
                courseName: String(localized: "American literature IV", comment: "Example course name"),
                courseColor: .textSuccess)
        ])
    }

    let announcements: [AnnouncementItem]

    init(isLoggedIn: Bool = true, announcementItems: [AnnouncementItem] = []) {
        self.announcements = announcementItems
        super.init(isLoggedIn: isLoggedIn)
    }
}

extension AnnouncementsEntry: Identifiable {
    var id: Int {
        var hasher = Hasher()
        announcements.forEach { hasher.combine($0.id) }
        hasher.combine(isLoggedIn)
        return hasher.finalize()
    }
}

#if DEBUG
extension AnnouncementsEntry {
    public static func make() -> AnnouncementsEntry {
        let url = URL(string: "https://www.instructure.com/")!

        return AnnouncementsEntry(announcementItems: [
            AnnouncementItem(title: "Finals are moving to next week.", date: Date(), url: url, authorName: "Thomas McKempis", courseName: "Introduction to the Solar System", courseColor: .electric),
            AnnouncementItem(title: "Zoo Field Trip!", date: Date().addDays(-1), url: url, authorName: "Susan Jorgenson", courseName: "Biology 201", courseColor: .course3),
            AnnouncementItem(title: "Read Moby Dick by end of week.", date: Date().addDays(-5), url: url, authorName: "Janet Hammond", courseName: "American literature IV", courseColor: .textSuccess),
            AnnouncementItem(title: "Zoo Field Trip!", date: Date().addDays(-1), url: url, authorName: "Susan Jorgenson", courseName: "Biology 201", courseColor: .course3),
            AnnouncementItem(title: "Read Moby Dick by end of week.", date: Date().addDays(-5), url: url, authorName: "Janet Hammond", courseName: "American literature IV", courseColor: .textSuccess)
        ])
    }
}
#endif
