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
import Combine
import Foundation

final class NotificationInteractorMock: NotificationInteractor {
    private let shouldReturnError: Bool
    var mockedNotifications: [NotificationModel]?
    init(shouldReturnError: Bool = false) {
        self.shouldReturnError = shouldReturnError
    }
    private let mocks: [NotificationModel] = [
        NotificationModel(
            id: "1",
            title: "Title 1",
            date: Date(),
            isRead: false,
            courseName: "Course 1",
            courseID: "1",
            enrollmentID: "enrollmentID-1",
            isScoreAnnouncement: false,
            type: .score,
            announcementId: "announcementId-1",
            assignmentURL: URL(string: "https://course/1/assignment"),
            htmlURL: nil
        ),
        NotificationModel(
            id: "2",
            title: "Title 2",
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()),
            isRead: true,
            courseName: "Course 2",
            courseID: "2",
            enrollmentID: "enrollmentID-2",
            isScoreAnnouncement: false,
            type: .scoreChanged,
            announcementId: "announcementId-2",
            assignmentURL: URL(string: "https://course/2/assignment"),
            htmlURL: URL(string: "https://course/2/html")
        ),
        NotificationModel(
            id: "3",
            title: "Title 3",
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date()),
            isRead: false,
            courseName: "Course 3",
            courseID: "3",
            enrollmentID: "enrollmentID-3",
            isScoreAnnouncement: true,
            type: .dueDate,
            announcementId: "announcementId-3",
            assignmentURL: URL(string: "https://course/3/assignment"),
            htmlURL: URL(string: "https://course/3/html")
        ),
        NotificationModel(
            id: "4",
            title: "Title 4",
            date: Calendar.current.date(byAdding: .day, value: -3, to: Date()),
            isRead: true,
            courseName: "Course 4",
            courseID: "4",
            enrollmentID: "enrollmentID-4",
            isScoreAnnouncement: false,
            type: .announcement,
            announcementId: "announcementId-4",
            assignmentURL: nil,
            htmlURL: URL(string: "https://course/4/html")
        ),
        NotificationModel(
            id: "5",
            title: "Title 5",
            date: Calendar.current.date(byAdding: .day, value: -4, to: Date()),
            isRead: false,
            courseName: "Course 5",
            courseID: "5",
            enrollmentID: "enrollmentID-5",
            isScoreAnnouncement: true,
            type: .score,
            announcementId: "announcementId-5",
            assignmentURL: URL(string: "https://course/5/assignment"),
            htmlURL: nil
        ),
        NotificationModel(
            id: "6",
            title: "Title 6",
            date: Calendar.current.date(byAdding: .day, value: -5, to: Date()),
            isRead: true,
            courseName: "Course 6",
            courseID: "6",
            enrollmentID: "enrollmentID-6",
            isScoreAnnouncement: false,
            type: .scoreChanged,
            announcementId: "announcementId-6",
            assignmentURL: URL(string: "https://course/6/assignment"),
            htmlURL: URL(string: "https://course/6/html")
        ),
        NotificationModel(
            id: "7",
            title: "Title 7",
            date: Calendar.current.date(byAdding: .day, value: -6, to: Date()),
            isRead: false,
            courseName: "Course 7",
            courseID: "7",
            enrollmentID: "enrollmentID-7",
            isScoreAnnouncement: true,
            type: .dueDate,
            announcementId: "announcementId-7",
            assignmentURL: URL(string: "https://course/7/assignment"),
            htmlURL: URL(string: "https://course/7/html")
        ),
        NotificationModel(
            id: "8",
            title: "Title 8",
            date: Calendar.current.date(byAdding: .day, value: -7, to: Date()),
            isRead: true,
            courseName: "Course 8",
            courseID: "8",
            enrollmentID: "enrollmentID-8",
            isScoreAnnouncement: false,
            type: .announcement,
            announcementId: "announcementId-8",
            assignmentURL: nil,
            htmlURL: URL(string: "https://course/8/html")
        ),
        NotificationModel(
            id: "9",
            title: "Title 9",
            date: Calendar.current.date(byAdding: .day, value: -8, to: Date()),
            isRead: false,
            courseName: "Course 9",
            courseID: "9",
            enrollmentID: "enrollmentID-9",
            isScoreAnnouncement: true,
            type: .score,
            announcementId: "announcementId-9",
            assignmentURL: URL(string: "https://course/9/assignment"),
            htmlURL: nil
        ),
        NotificationModel(
            id: "10",
            title: "Title 10",
            date: Calendar.current.date(byAdding: .day, value: -9, to: Date()),
            isRead: true,
            courseName: "Course 10",
            courseID: "10",
            enrollmentID: "enrollmentID-10",
            isScoreAnnouncement: false,
            type: .scoreChanged,
            announcementId: "announcementId-10",
            assignmentURL: URL(string: "https://course/10/assignment"),
            htmlURL: URL(string: "https://course/10/html")
        ),
        NotificationModel(
            id: "13",
            title: "Title 13",
            date: Calendar.current.date(byAdding: .day, value: -9, to: Date()),
            isRead: true,
            courseName: "Course 13",
            courseID: "13",
            enrollmentID: "enrollmentID-13",
            isScoreAnnouncement: false,
            type: .scoreChanged,
            announcementId: "announcementId-13",
            assignmentURL: URL(string: "https://course/13/assignment"),
            htmlURL: URL(string: "https://course/13/html")
        ),
        NotificationModel(
            id: "11",
            title: "Title 11",
            date: Calendar.current.date(byAdding: .day, value: -10, to: Date()),
            isRead: false,
            courseName: "Course 11",
            courseID: "11",
            enrollmentID: "enrollmentID-11",
            isScoreAnnouncement: true,
            type: .dueDate,
            announcementId: "announcementId-11",
            assignmentURL: URL(string: "https://course/11/assignment"),
            htmlURL: URL(string: "https://course/11/html")
        ),
        NotificationModel(
            id: "12",
            title: "Title 12",
            date: Calendar.current.date(byAdding: .day, value: -10, to: Date()),
            isRead: false,
            courseName: "Course 12",
            courseID: "11",
            enrollmentID: "enrollmentID-12",
            isScoreAnnouncement: true,
            type: .dueDate,
            announcementId: "announcementId-12",
            assignmentURL: URL(string: "https://course/12/assignment"),
            htmlURL: URL(string: "https://course/12/html")
        )
    ]

    func getNotifications(ignoreCache: Bool) -> AnyPublisher<[NotificationModel], Error> {
        if shouldReturnError {
            return Fail(error: NSError(domain: "NotificationInteractorMock", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock error"]))
                .eraseToAnyPublisher()
        } else {
            return Just(mockedNotifications ?? mocks)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }

    func getUnreadNotificationCount() -> AnyPublisher<Int, Never> {
        Just(3)
            .eraseToAnyPublisher()
    }

    func markNotificationAsRead(notification: NotificationModel) -> AnyPublisher<[NotificationModel], any Error> {
        if shouldReturnError {
            return Fail(error: NSError(domain: "NotificationInteractorMock", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock error"]))
                .eraseToAnyPublisher()
        } else {
            return Just(
                [
                    NotificationModel(
                        id: "10",
                        title: "Title 10",
                        date: Calendar.current.date(byAdding: .day, value: -9, to: Date()),
                        isRead: false,
                        courseName: "Course 10",
                        courseID: "10",
                        enrollmentID: "enrollmentID-10",
                        isScoreAnnouncement: false,
                        type: .announcement,
                        announcementId: "announcementId-10",
                        assignmentURL: URL(string: "https://course/10/assignment"),
                        htmlURL: URL(string: "https://course/10/html")
                    ),
                    NotificationModel(
                        id: "11",
                        title: "Title 11",
                        date: Calendar.current.date(byAdding: .day, value: -10, to: Date()),
                        isRead: false,
                        courseName: "Course 11",
                        courseID: "11",
                        enrollmentID: "enrollmentID-11",
                        isScoreAnnouncement: true,
                        type: .dueDate,
                        announcementId: "announcementId-11",
                        assignmentURL: URL(string: "https://course/11/assignment"),
                        htmlURL: URL(string: "https://course/11/html")
                    )
                ]
            )
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        }
    }
}
