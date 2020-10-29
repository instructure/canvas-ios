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
import WidgetKit

struct AnnouncementsEntry: TimelineEntry {
    var date = Date(timeIntervalSince1970: 0)
    let announcements: [AnnouncementItem]

    init(announcementItems: [AnnouncementItem]) {
        self.announcements = announcementItems
    }

    public static func makePreview() -> AnnouncementsEntry {
        AnnouncementsEntry(announcementItems: [
            AnnouncementItem(title: "Finals are moving to another week.", date: Date(), url: URL(string: "https://www.instructure.com/")!, authorName: "Thomas McKempis", courseName: "Introduction to the solar system", courseColor: .electric),
            AnnouncementItem(title: "Zoo Field Trip!", date: Date().addDays(-1), url: URL(string: "https://www.instructure.com/")!, authorName: "Susan Jorgenson", courseName: "Biology 201", courseColor: .barney),
            AnnouncementItem(title: "Read Moby Dick by end of week.", date: Date().addDays(-5), url: URL(string: "https://www.instructure.com/")!, authorName: "Janet Hammond", courseName: "American literature IV", courseColor: .shamrock)
        ])
    }

}
