//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

struct InboxMessageModel: Equatable, Identifiable {
    let announcement: AnnouncementModel?
    let inboxMessageListItem: InboxMessageListItem?

    var date: Date? {
        announcement?.date ?? inboxMessageListItem?.dateRaw
    }
    var dateString: String {
        date.map { $0.relativeDateTimeString } ?? ""
    }

    var title: String {
        guard let announcement else { return inboxMessageListItem?.title ?? "" }

        guard let courseName = announcement.courseName else {
            return String(localized: "Announcement", bundle: .horizon)
        }
        return String(
            format: String(localized: "Announcement in %@"),
            courseName
        )
    }
    var subtitle: String {
        announcement?.title
        ?? inboxMessageListItem?.participantName
        ?? ""
    }

    var isAnnouncement: Bool {
        inboxMessageListItem == nil
    }

    var isNew: Bool {
        inboxMessageListItem?.isUnread == true || announcement?.isRead == false
    }
    var id: String {
        if let announcement {
            return "announcement_\(announcement.id)"
        }
        return "message_\(inboxMessageListItem?.id ?? "")"
    }
}
