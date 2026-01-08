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
    // MARK: - Propertites

    let announcement: AnnouncementModel?
    let date: Date?
    let dateString: String
    let isNew: Bool
    let messageListItemID: String?
    let isAnnouncement: Bool
    let subtitle: String
    let messageTitle: String

    // MARK: - Init

    init(
        announcement: AnnouncementModel?,
        date: Date?,
        dateString: String,
        isNew: Bool,
        messageListItemID: String?,
        isAnnouncement: Bool,
        subtitle: String,
        messageTitle: String
    ) {
        self.announcement = announcement
        self.date = date
        self.dateString = dateString
        self.isNew = isNew
        self.messageListItemID = messageListItemID
        self.isAnnouncement = isAnnouncement
        self.subtitle = subtitle
        self.messageTitle = messageTitle
    }

    init(
        announcement: AnnouncementModel?,
        entity: InboxMessageListItem?
    ) {
        self.announcement = announcement
        self.date = announcement?.date ?? entity?.dateRaw
        self.isAnnouncement = entity == nil
        self.messageTitle = (entity?.title).defaultToEmpty
        self.messageListItemID = entity?.id
        self.dateString = (announcement?.date ?? entity?.dateRaw).map { $0.relativeDateTimeString } ?? ""
        self.subtitle = (announcement?.title ?? entity?.participantName).defaultToEmpty
        self.isNew = entity?.isUnread == true || announcement?.isRead == false
    }

    var title: String {
        guard let announcement else { return messageTitle }
        guard let courseName = announcement.courseName else {
            return String(localized: "Announcement", bundle: .horizon)
        }
        return String(
            format: String(localized: "Announcement in %@"),
            courseName
        )
    }

    var id: String {
        if let announcement {
            return "announcement_\(announcement.id)"
        }
        return "message_\(messageListItemID.defaultToEmpty)"
    }
}
