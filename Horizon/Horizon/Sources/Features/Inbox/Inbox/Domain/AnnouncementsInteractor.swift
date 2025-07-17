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

import Combine
import CombineExt
import Core
import Foundation

struct Announcement: Equatable, Identifiable, Hashable {
    let author: String
    let courseName: String?
    let date: Date?
    let id: String
    let isAccountAnnouncement: Bool
    let title: String
}

protocol AnnouncementsInteractor {
    var messages: CurrentValueSubject<[Announcement]?, Never> { get }
    var state: CurrentValueRelay<StoreState> { get }
}

class AnnouncementsInteractorLive: AnnouncementsInteractor {
    // MARK: - Outputs
    let messages = CurrentValueSubject<[Announcement]?, Never>([])
    let state = CurrentValueRelay<StoreState>(.empty)

    // MARK: - Private
    private var accountAnnouncements: CurrentValueSubject<[Announcement]?, any Error> = .init(nil)
    private var accountNotificationsStore: ReactiveStore<GetAccountNotifications>?
    private var announcementsStore: ReactiveStore<GetAnnouncementsUseCase>?
    private var courseAnnouncements: CurrentValueSubject<[Announcement]?, any Error> = .init(nil)
    private var coursesProgressionStore: ReactiveStore<GetHCoursesProgressionUseCase>?
    private var subscriptions: Set<AnyCancellable> = []

    // MARK: - Init
    init(userID: String = AppEnvironment.shared.currentSession?.userID ?? "") {
        listenForAccountNotifications()
        listenForCourseAnnouncements(userID)
        listenForCombinedAnnouncements()
    }

    // MARK: - Private
    private func listenForAccountNotifications() {
        ReactiveStore(useCase: GetAccountNotifications())
            .getEntities()
            .map { $0.map { $0.announcement} }
            .subscribe(accountAnnouncements)
            .store(in: &subscriptions)
    }

    private func listenForAnnouncements(from courses: [CDHCourse]) -> AnyPublisher<[Announcement], any Error> {
        ReactiveStore(
            useCase: GetAnnouncementsUseCase(
                courseIds: courses.map { $0.courseID },
                activeOnly: nil,
                latestOnly: nil,
                startDate: Date.now.addYears(-1),
                endDate: Date.now
            )
        )
        .getEntities()
        .map { discussionTopics in
            discussionTopics.map { discussionTopic in
                discussionTopic.announcement(
                    author: discussionTopic.author?.displayName ?? "",
                    courseName: courses.first { $0.courseID == discussionTopic.courseID }?.course.name
                )
            }
        }
        .eraseToAnyPublisher()
    }

    private func listenForCourseAnnouncements(_ userID: String) {
        ReactiveStore(
            useCase: GetHCoursesProgressionUseCase(userId: userID, horizonCourses: true)
        )
        .getEntities()
        .flatMap { [weak self] courses in
            self?.listenForAnnouncements(from: courses) ?? Empty<[Announcement], any Error>().eraseToAnyPublisher()
        }
        .compactMap { $0 }
        .subscribe(courseAnnouncements)
        .store(in: &subscriptions)
    }

    private func listenForCombinedAnnouncements() {
        Publishers.CombineLatest(
            accountAnnouncements,
            courseAnnouncements
        ).map { account, course in
            guard let account = account, let course = course else {
                return nil
            }
            return (account + course).sorted { $0.date ?? Date.distantPast > $1.date ?? Date.distantPast }
        }
        .compactMap { $0 }
        .replaceError(with: [])
        .subscribe(messages)
        .store(in: &subscriptions)
    }
}

extension AccountNotification {
    var announcement: Announcement {
        Announcement(
            author: "",
            courseName: nil,
            date: startAt ?? endAt,
            id: id,
            isAccountAnnouncement: true,
            title: subject
        )
    }
}

extension DiscussionTopic {
    func announcement(author: String, courseName: String?) -> Announcement {
        Announcement(
            author: author,
            courseName: courseName,
            date: postedAt,
            id: id,
            isAccountAnnouncement: false,
            title: title ?? ""
        )
    }
}
