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
    func getNotifications(ignoreCache: Bool) -> AnyPublisher<[NotificationModel], Never>
    func getUnreadNotificationCount() -> AnyPublisher<Int, Never>
}

final class NotificationInteractorLive: NotificationInteractor {
    // MARK: - Dependencies

    private let userID: String
    private let formatter: NotificationFormatter

    // MARK: - Init

    init(
        userID: String,
        formatter: NotificationFormatter
    ) {
        self.userID = userID
        self.formatter = formatter
    }

    func getNotifications(ignoreCache: Bool) -> AnyPublisher<[NotificationModel], Never> {
        Publishers.Zip3(
            fetchNotifications(ignoreCache: ignoreCache),
            fetchCourses(),
            fetchGlobalNotifications(ignoreCache: ignoreCache)
        )
        .map { [weak self] activities, courses, globalNotifications -> [NotificationModel] in
            var localNotifications = self?.formatter.formatNotifications(activities, courses: courses) ?? []
            localNotifications.append(contentsOf: globalNotifications)
            return localNotifications.sorted { ($0.date ?? Date()) > ($1.date ?? Date()) }
        }
        .eraseToAnyPublisher()
    }

    func getUnreadNotificationCount() -> AnyPublisher<Int, Never> {
        Publishers.Zip(fetchNotifications(ignoreCache: true), fetchCourses())
            .map { [weak self] activities, courses -> [NotificationModel] in
                self?.formatter.formatNotifications(activities, courses: courses) ?? []
            }
            .map { notifications in
                notifications.reduce(0) { count, notification in
                    notification.isRead ? count : count + 1
                }
            }
            .replaceError(with: 0)
            .eraseToAnyPublisher()
    }

    private func fetchNotifications(ignoreCache: Bool) -> AnyPublisher<[HActivity], Never> {
        ReactiveStore(useCase: GetActivities(onlyActiveCourses: true))
            .getEntities(ignoreCache: ignoreCache)
            .replaceError(with: [])
            .flatMap { Publishers.Sequence(sequence: $0)}
            .map { HActivity(from: $0) }
            .collect()
            .eraseToAnyPublisher()
    }

    private func fetchCourses() -> AnyPublisher<[HCourse], Never> {
        ReactiveStore(useCase: GetHCoursesProgressionUseCase(userId: userID))
            .getEntities()
            .replaceError(with: [])
            .flatMap { Publishers.Sequence(sequence: $0)}
            .map { HCourse(from: $0, modules: []) }
            .collect()
            .eraseToAnyPublisher()
    }

    private func fetchGlobalNotifications(ignoreCache: Bool) -> AnyPublisher<[NotificationModel], Never> {
        ReactiveStore(useCase: GetAccountNotifications())
            .getEntities(ignoreCache: ignoreCache)
            .replaceError(with: [])
            .flatMap { Publishers.Sequence(sequence: $0) }
            .map {
                NotificationModel(
                    id: $0.id,
                    title: $0.subject,
                    date: $0.startAt,
                    isRead: true,
                    type: .announcement,
                    announcementId: $0.id
                )
            }
            .collect()
            .eraseToAnyPublisher()
    }
}
