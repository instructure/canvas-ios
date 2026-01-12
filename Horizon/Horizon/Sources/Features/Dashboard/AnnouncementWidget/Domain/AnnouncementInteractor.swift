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

import Core
import Combine
import Foundation

protocol AnnouncementInteractor {
    func getAllAnnouncements(ignoreCache: Bool) -> AnyPublisher<[AnnouncementModel], Never>
    func markAnnouncementAsRead(announcement: AnnouncementModel) -> AnyPublisher<[AnnouncementModel], Never>
}

final class AnnouncementInteractorLive: AnnouncementInteractor {
    // MARK: - Dependencies

    private let userID: String
    private let isIncludePast: Bool
    private let learnCoursesInteractor: GetLearnCoursesInteractor

    // MARK: - Init

    init(
        userID: String,
        isIncludePast: Bool,
        learnCoursesInteractor: GetLearnCoursesInteractor
    ) {
        self.userID = userID
        self.isIncludePast = isIncludePast
        self.learnCoursesInteractor = learnCoursesInteractor
    }

    // MARK: - Public Functions

    func getAllAnnouncements(ignoreCache: Bool) -> AnyPublisher<[AnnouncementModel], Never> {
        Publishers.Zip(
            getAnnouncements(ignoreCache: ignoreCache),
            fetchGlobalNotifications(ignoreCache: ignoreCache)
        )
        .map { announcements, globalAnnouncements in
            (announcements + globalAnnouncements)
                .sorted {($0.date ?? .distantPast) > ($1.date ?? .distantPast)}
        }
        .eraseToAnyPublisher()
    }

    func markAnnouncementAsRead(announcement: AnnouncementModel) -> AnyPublisher<[AnnouncementModel], Never> {
        guard !announcement.isRead else {
            return self.getAllAnnouncements(ignoreCache: false)
        }
        if announcement.isGlobal {
            return deleteAccountNotification(id: announcement.id)

        } else {
            return markDiscussionTopicRead(
                courseID: announcement.courseID.defaultToEmpty,
                topicID: announcement.id
            )
        }
    }

    // MARK: - Private Functions

    private func fetchGlobalNotifications(ignoreCache: Bool) -> AnyPublisher<[AnnouncementModel], Never> {
        ReactiveStore(useCase: GetAccountNotifications(includePast: isIncludePast))
            .getEntities(ignoreCache: ignoreCache)
            .replaceError(with: [])
            .flatMap { Publishers.Sequence(sequence: $0) }
            .map { AnnouncementModel(entity: $0)}
            .collect()
            .eraseToAnyPublisher()
    }

    private func getAnnouncements(ignoreCache: Bool) -> AnyPublisher<[AnnouncementModel], Never> {
        fetchCourses()
            .flatMap { [weak self] courses -> AnyPublisher<[AnnouncementModel], Never> in
                guard let self else {
                    return Just([]).eraseToAnyPublisher()
                }
                return self.fetchAnnouncements(
                    courses: courses,
                    ignoreCache: ignoreCache
                )
            }
            .eraseToAnyPublisher()
    }

    private func fetchAnnouncements(
        courses: [LearnCourse],
        ignoreCache: Bool
    ) -> AnyPublisher<[AnnouncementModel], Never> {
        let useCase = GetAnnouncementsUseCase(
            courseIds: courses.map { $0.id },
            activeOnly: nil,
            latestOnly: nil,
            startDate: Date.now.addYears(-1),
            endDate: Date.now
        )
        return ReactiveStore(useCase: useCase)
            .getEntities(ignoreCache: ignoreCache)
            .replaceError(with: [])
            .flatMap { Publishers.Sequence(sequence: $0) }
            .map { AnnouncementModel(entity: $0, courses: courses) }
            .collect()
            .eraseToAnyPublisher()
    }

    private func fetchCourses() -> AnyPublisher<[LearnCourse], Never> {
        learnCoursesInteractor
            .getCourses(ignoreCache: false)
            .eraseToAnyPublisher()
    }

    private func markDiscussionTopicRead(courseID: String, topicID: String) -> AnyPublisher<[AnnouncementModel], Never> {
        let useCase = MarkDiscussionTopicRead(
            context: .course(courseID),
            topicID: topicID,
            isRead: true
        )
        return ReactiveStore(useCase: useCase)
            .getEntities(ignoreCache: true)
            .replaceError(with: [])
            .flatMap { [weak self] _ -> AnyPublisher<[AnnouncementModel], Never> in
                guard let self = self else {
                    return Just([]).eraseToAnyPublisher()
                }
                return self.getAllAnnouncements(ignoreCache: true)
            }
            .eraseToAnyPublisher()
    }

    private func deleteAccountNotification(id: String) -> AnyPublisher<[AnnouncementModel], Never> {
        ReactiveStore(useCase: DeleteAccountNotification(id: id))
            .getEntities(ignoreCache: true)
            .replaceError(with: [])
            .flatMap { [weak self] _ -> AnyPublisher<[AnnouncementModel], Never> in
                guard let self = self else {
                    return Just([]).eraseToAnyPublisher()
                }
                return self.getAllAnnouncements(ignoreCache: true)
            }
            .eraseToAnyPublisher()
    }
}
