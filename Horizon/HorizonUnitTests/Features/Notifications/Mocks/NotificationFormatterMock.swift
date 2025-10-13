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

@testable import Horizon
import Foundation

final class NotificationFormatterMock: NotificationFormatter {
    func formatNotifications(_ notifications: [HActivity], courses: [HCourse]) -> [NotificationModel] {
        [
            .init(
                id: "1",
                title: "Title 1",
                date: Date(),
                isRead: false,
                courseName: "Course 1",
                courseID: "1",
                enrollmentID: "enrollmentID-1",
                isScoreAnnouncement: false,
                type: .scoreChanged,
                announcementId: "announcementId-1",
                assignmentURL: URL(string: "https://course/1231/123"),
                htmlURL: nil
            ),
            .init(
                id: "2",
                title: "Title 2",
                date: Date(),
                isRead: true,
                courseName: "Course 3",
                courseID: "2",
                enrollmentID: "enrollmentID-3",
                isScoreAnnouncement: false,
                type: .dueDate,
                announcementId: "announcementId-3",
                assignmentURL: URL(string: "https://course/1231/123"),
                htmlURL: nil
            )
        ]
    }
}
