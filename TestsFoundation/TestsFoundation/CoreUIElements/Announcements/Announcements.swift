//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

import XCTest

public enum Announcements: ElementWrapper {

    public static var emptyAnnouncements: Element {
        return app.find(label: "No Announcements")
    }

    public static var addNewAnnouncement: Element {
        return app.find(label: "Create Announcement")
    }

    public static func announcementByTitle(title: String) -> Element {
        return app.find(labelContaining: title)
    }
}

public enum AnnouncementsDetails: ElementWrapper {

    public static var optionButton: Element {
        app.find(label: "Options")
    }

    public static func detailsByText(text: String) -> Element {
        return app.find(label: text)
    }

    public static var replyButton: Element {
        app.find(label: "Reply to main discussion")
    }
}

public enum EditAnnouncements: ElementWrapper {
    case title, description, done
    public static var editAnnouncement: Element {
        app.find(label: "Edit Announcement")
    }
}

public enum AnnouncementList {
    public static func announcement(index: Int) -> Element {
        return app.find(id: "announcements.list.announcement.row-\(index)")
    }
}
