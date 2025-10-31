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

import Foundation
import Combine

#if DEBUG
final class NotificationInteractorPreview: NotificationInteractor {
    func getNotifications(ignoreCache: Bool) -> AnyPublisher<[NotificationModel], Error> {
        Just([
            .init(
                id: "1",
                title: "[first two lines of the message......... there’s more.].",
                date: Date(),
                isRead: false,
                courseName: "course Name One",
                courseID: "12",
                enrollmentID: "1211",
                isScoreAnnouncement: false,
                type: .announcement,
                announcementId: "1",
                assignmentURL: nil

            ),
            .init(
                id: "2",
                title: "[first two lines of the message.",
                date: Date(),
                isRead: false,
                courseName: "course Name Two",
                courseID: "12",
                enrollmentID: "1211",
                isScoreAnnouncement: false,
                type: .announcement,
                announcementId: "1",
                assignmentURL: nil

            )
        ])
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    }

    func getUnreadNotificationCount() -> AnyPublisher<Int, Never> {
        Just(3).eraseToAnyPublisher()
    }

    func markNotificationAsRead(notification: NotificationModel) -> AnyPublisher<[NotificationModel], Error> {
        Just([
            .init(
                id: "4",
                title: "[first two lines of the message......... there’s more.].",
                date: Date(),
                isRead: true,
                courseName: "course Name",
                courseID: "1552",
                enrollmentID: "1211",
                isScoreAnnouncement: false,
                type: .announcement,
                announcementId: "1",
                assignmentURL: nil

            ),
            .init(
                id: "5",
                title: "[first two lines of the message......... there’s more.].",
                date: Date(),
                isRead: false,
                courseName: "course Name",
                courseID: "122",
                enrollmentID: "1211",
                isScoreAnnouncement: false,
                type: .announcement,
                announcementId: "1",
                assignmentURL: nil

            )
        ])
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    }
}
#endif
