//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

final class AnnouncementInteractorMock: AnnouncementInteractor {
    private let shouldReturnError: Bool
    var mockedAnnouncements: [AnnouncementModel]?

    // MARK: - Call Tracking
    var getAllAnnouncementsCallCount = 0
    var markAnnouncementAsReadCallCount = 0
    var lastGetAllAnnouncementsIgnoreCache: Bool?
    var lastMarkedAnnouncementAsRead: AnnouncementModel?

    init(shouldReturnError: Bool = false) {
        self.shouldReturnError = shouldReturnError
    }

    private let mocks: [AnnouncementModel] = [
        AnnouncementModel(
            id: "1",
            title: "Important Course Update",
            content: "Please review the updated course materials",
            courseID: "course-1",
            courseName: "iOS Development 101",
            date: Date(),
            isRead: false,
            isGlobal: false
        ),
        AnnouncementModel(
            id: "2",
            title: "Global Announcement",
            content: "System maintenance scheduled",
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()),
            isRead: false,
            isGlobal: true
        ),
        AnnouncementModel(
            id: "3",
            title: "Assignment Reminder",
            content: "Don't forget your assignment due tomorrow",
            courseID: "course-2",
            courseName: "Swift Programming",
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date()),
            isRead: false,
            isGlobal: false
        )
    ]

    func getAllAnnouncements(ignoreCache: Bool) -> AnyPublisher<[AnnouncementModel], Never> {
        getAllAnnouncementsCallCount += 1
        lastGetAllAnnouncementsIgnoreCache = ignoreCache
        if shouldReturnError {
            return Just([]).eraseToAnyPublisher()
        } else {
            return Just(mockedAnnouncements ?? mocks)
                .eraseToAnyPublisher()
        }
    }

    func markAnnouncementAsRead(announcement: AnnouncementModel) -> AnyPublisher<[AnnouncementModel], Never> {
        markAnnouncementAsReadCallCount += 1
        lastMarkedAnnouncementAsRead = announcement
        if shouldReturnError {
            return Just([]).eraseToAnyPublisher()
        } else {
            let updatedAnnouncements = (mockedAnnouncements ?? mocks).filter { $0.id != announcement.id || $0.isRead }
            return Just(updatedAnnouncements)
                .eraseToAnyPublisher()
        }
    }
}
