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
import Core

protocol NotificationInteractor {
    func getNotifications(ignoreCache: Bool) -> AnyPublisher<[NotificationModel], Error>
    func getUnreadNotificationCount() -> AnyPublisher<Int, Never>
}

final class NotificationInteractorLive: NotificationInteractor {
    // MARK: - Dependencies

    private let userID: String
    private let includePast: Bool
    private let formatter: NotificationFormatter

    // MARK: - Init

    init(
        userID: String,
        includePast: Bool = false,
        formatter: NotificationFormatter
    ) {
        self.userID = userID
        self.includePast = includePast
        self.formatter = formatter
    }

    func getNotifications(ignoreCache: Bool) -> AnyPublisher<[NotificationModel], Error> {
        let notificationsPublisher = fetchNotifications(ignoreCache: ignoreCache)
        let coursesPublisher = fetchCourses()
            .setFailureType(to: Error.self)

        return Publishers.Zip(
            notificationsPublisher,
            coursesPublisher
        )
        .map { [weak self] activities, courses -> [NotificationModel] in
            let localNotifications = self?.formatter.formatNotifications(activities, courses: courses) ?? []
            return localNotifications.sorted { ($0.date ?? Date()) > ($1.date ?? Date()) }
        }
        .eraseToAnyPublisher()
    }

    func getUnreadNotificationCount() -> AnyPublisher<Int, Never> {
        let notificationsPublisher = fetchNotifications(ignoreCache: true)
            .replaceError(with: [])
        let coursesPublisher = fetchCourses()

        return Publishers.Zip(
            notificationsPublisher,
            coursesPublisher
        )
        .map { [weak self] activities, courses -> [NotificationModel] in
            self?.formatter.formatNotifications(activities, courses: courses) ?? []
        }
        .flatMap { Publishers.Sequence(sequence: $0) }
        .filter { $0.type != .announcement }
        .collect()
        .map { notifications in
            notifications.reduce(0) { count, notification in
                notification.isRead ? count : count + 1
            }
        }
        .eraseToAnyPublisher()
    }

    private func fetchNotifications(ignoreCache: Bool) -> AnyPublisher<[HActivity], Error> {
        ReactiveStore(useCase: GetActivities(onlyActiveCourses: true))
            .getEntities(ignoreCache: ignoreCache)
            .map { activities in
                activities.map { HActivity(from: $0) }
            }
            .eraseToAnyPublisher()
    }

    private func fetchCourses() -> AnyPublisher<[HCourse], Never> {
        ReactiveStore(useCase: GetHCoursesProgressionUseCase(userId: userID, horizonCourses: true))
            .getEntities()
            .replaceError(with: [])
            .flatMap { Publishers.Sequence(sequence: $0)}
            .map { HCourse(from: $0, modules: []) }
            .collect()
            .eraseToAnyPublisher()
    }
}
