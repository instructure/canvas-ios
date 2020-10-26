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

struct AnnouncementItem: Identifiable {
    let id = UUID()
    let message: String

    init?(_ activity: Activity) {
        guard let title = activity.title else { return nil }
        message = title
    }

    init(message: String) {
        self.message = message
    }
}

struct AnnouncementsEntry: TimelineEntry {
    var date: Date
    let announcements: [AnnouncementItem]

    init(_ activities: [Activity]) {
        date = Date()
        announcements = activities.compactMap { AnnouncementItem($0) }
    }

    init(announcementItems: [AnnouncementItem]) {
        date = Date()
        self.announcements = announcementItems
    }
}
