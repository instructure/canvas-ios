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

struct NotificationModel: Identifiable, Equatable {
    let id: String
    let title: String
    let date: Date?
    let isRead: Bool
    let courseName: String?
    let courseID: String
    let enrollmentID: String
    let isScoreAnnouncement: Bool
    let type: NotificationType
    let announcementId: String?
    let assignmentURL: URL?
    let htmlURL: URL?
    let isGlobalNotification: Bool

    init(
        id: String,
        title: String,
        date: Date?,
        isRead: Bool,
        courseName: String? = nil,
        courseID: String = "",
        enrollmentID: String = "''",
        isScoreAnnouncement: Bool = false,
        type: NotificationType,
        announcementId: String? = nil,
        assignmentURL: URL? = nil,
        htmlURL: URL? = nil,
        isGlobalNotification: Bool = false
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.isRead = isRead
        self.courseName = courseName
        self.courseID = courseID
        self.enrollmentID = enrollmentID
        self.isScoreAnnouncement = isScoreAnnouncement
        self.type = type
        self.announcementId = announcementId
        self.assignmentURL = assignmentURL
        self.htmlURL = htmlURL
        self.isGlobalNotification = isGlobalNotification
    }

    var dateFormatted: String {
        guard let date else { return "" }

        let calendar = Calendar.current
        let now = Date()

        switch true {
        case calendar.isDateInToday(date):
            return String(localized: "Today", bundle: .horizon)
        case calendar.isDateInYesterday(date):
            return String(localized: "Yesterday", bundle: .horizon)
        case calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear):
            return Date.weekdayFormatter.string(from: date)
        default:
            return date.formatted(format: "MMM d, yyyy")
        }
    }

    static let mock: Self = .init(
        id: "1",
        title: "Title 1",
        date: Date(),
        isRead: false,
        courseName: "Course name",
        type: .announcement
    )

    var accessibilityCourseName: String {
        String.localizedStringWithFormat(String(localized: "Course %@", bundle: .horizon), courseName.defaultToEmpty)
    }

    var accessibilityDate: String {
        String.localizedStringWithFormat(String(localized: "Date %@", bundle: .horizon), dateFormatted)
    }

    var accessibilityTitle: String {
        String.localizedStringWithFormat(String(localized: "Title %@", bundle: .horizon), title)
    }

    // Returns true if the notification's date is within the last 14 days.
    // If date is nil, returns false.
    var isWithinTwoWeeksLimit: Bool {
        guard let date else { return false }
        // Calculate the cutoff date (14 days ago)
        let cutoff = Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date.distantPast
        return date >= cutoff
    }
}
