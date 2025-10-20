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
    func markNotificationAsRead(notification: NotificationModel) -> AnyPublisher<[NotificationModel], Error>
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

    func getNotifications(ignoreCache: Bool) -> AnyPublisher<[NotificationModel], Error> {
        let notificationsPublisher = fetchNotifications(ignoreCache: ignoreCache)
        let coursesPublisher = fetchCourses()
            .setFailureType(to: Error.self)
        let globalNotificationsPublisher = fetchGlobalNotifications(ignoreCache: ignoreCache)
            .setFailureType(to: Error.self)

        return Publishers.Zip3(
            notificationsPublisher,
            coursesPublisher,
            globalNotificationsPublisher
        )
        .map { [weak self] activities, courses, globalNotifications -> [NotificationModel] in
            var localNotifications = self?.formatter.formatNotifications(activities, courses: courses) ?? []
            localNotifications.append(contentsOf: globalNotifications)
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
                    isRead: $0.closed,
                    type: .announcement,
                    announcementId: $0.id,
                    isGlobalNotification: true
                )
            }
            .collect()
            .eraseToAnyPublisher()
    }

    func markNotificationAsRead(notification: NotificationModel) -> AnyPublisher<[NotificationModel], Error> {
        if notification.isGlobalNotification {
            return deleteAccountNotification(id: notification.id)
        } else {
            return markDiscussionTopicRead(
                courseID: notification.courseID,
                topicID: notification.announcementId.defaultToEmpty
            )
        }
    }

    private func markDiscussionTopicRead(courseID: String, topicID: String) -> AnyPublisher<[NotificationModel], Error> {
        let useCase = HMarkDiscussionTopicReadUseCase(
            context: .course(courseID),
            topicID: topicID,
            isRead: true
        )
        return ReactiveStore(useCase: useCase)
            .getEntities(ignoreCache: true)
            .flatMap { [weak self] _ -> AnyPublisher<[NotificationModel], Error> in
                guard let self = self else {
                    return Just([])
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                return self.getNotifications(ignoreCache: true)
            }
            .eraseToAnyPublisher()
    }

    private func deleteAccountNotification(id: String) -> AnyPublisher<[NotificationModel], Error> {
        ReactiveStore(useCase: DeleteAccountNotification(id: id))
            .getEntities(ignoreCache: true)
            .flatMap { [weak self] _ -> AnyPublisher<[NotificationModel], Error> in
                guard let self = self else {
                    return Just([])
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                return self.getNotifications(ignoreCache: true)
            }
            .eraseToAnyPublisher()
    }
}
