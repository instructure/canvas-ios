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
    var messages: CurrentValueSubject<[Announcement], Never> { get }
}

class AnnouncementsInteractorLive: AnnouncementsInteractor {
    // MARK: - Outputs
    let messages = CurrentValueSubject<[Announcement], Never>([])

    // MARK: - Private
    private var announcements: [Announcement] {
        (accountAnnouncements + courseAnnouncements)
            .sorted { $0.date ?? Date.distantPast > $1.date ?? Date.distantPast }
    }
    private var subscriptions: Set<AnyCancellable> = []
    private var accountAnnouncements: [Announcement] = [] {
        didSet {
            sendAnnoucements()
        }
    }
    private var courseAnnouncements: [Announcement] = [] {
        didSet {
            sendAnnoucements()
        }
    }

    // MARK: - Init
    init(userID: String = AppEnvironment.shared.currentSession?.userID ?? "") {
        ReactiveStore(
            useCase: GetAccountNotifications(
                includePast: true,
                showIsClosed: true
            )
        )
        .getEntities()
        .replaceError(with: [])
        .sink { [weak self] accountNotifications in
            self?.accountAnnouncements = accountNotifications.map { $0.announcement }
        }
        .store(in: &subscriptions)

        ReactiveStore(useCase: GetCoursesProgressionUseCase(userId: userID, horizonCourses: true))
            .getEntities()
            .replaceError(with: [])
            .flatMap { courses in
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
                .replaceError(with: [])
            }
            .sink { [weak self] courseAnnouncements in
                self?.courseAnnouncements = courseAnnouncements
            }
            .store(in: &subscriptions)
    }

    // MARK: - Private
    private func sendAnnoucements() {
        messages.send(announcements)
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
