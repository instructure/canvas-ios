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
    var messages: CurrentValueRelay<[Announcement]> { get }
    var state: CurrentValueRelay<StoreState> { get }
}

class AnnouncementsInteractorLive: AnnouncementsInteractor {
    // MARK: - Outputs
    let messages = CurrentValueRelay<[Announcement]>([])
    let state = CurrentValueRelay<StoreState>(.empty)

    // MARK: - Private
    private var announcements: [Announcement] {
        let account = accountAnnouncements ?? []
        let course = courseAnnouncements ?? []
        return (account + course)
            .sorted { $0.date ?? Date.distantPast > $1.date ?? Date.distantPast }
    }
    private var accountNotificationsStore: Store<GetAccountNotifications>?
    private var announcementsStore: Store<GetAnnouncementsUseCase>?
    private var coursesProgressionStore: Store<GetCoursesProgressionUseCase>?

    private let environment: AppEnvironment
    private var subscriptions: Set<AnyCancellable> = []
    private var accountAnnouncements: [Announcement]? {
        didSet { trySendAnnouncements() }
    }
    private var courseAnnouncements: [Announcement]? {
        didSet { trySendAnnouncements() }
    }
    private let getAccountNotifications = GetAccountNotifications(
        includePast: true,
        showIsClosed: true
    )
    private let getAccountNotificationsState = CurrentValueSubject<StoreState, Never>(.empty)
    private let getAnnouncementsState = CurrentValueSubject<StoreState, Never>(.empty)
    private let coursesProgressionState = CurrentValueSubject<StoreState, Never>(.empty)

    // MARK: - Init
    init(
        environment: AppEnvironment = AppEnvironment.shared,
        userID: String = AppEnvironment.shared.currentSession?.userID ?? ""
    ) {
        self.environment = environment

        listenForAccountNotifications()
        listenForCourseAnnouncements(userID)

        listenForStateChanges()
    }

    // MARK: - Private
    private func listenForAccountNotifications() {
        accountNotificationsStore = environment.subscribe(getAccountNotifications)

        accountNotificationsStore?
            .statePublisher
            .subscribe(getAccountNotificationsState)
            .store(in: &subscriptions)

        accountNotificationsStore?
            .allObjects
            .sink { [weak self] accountNotifications in
                self?.accountAnnouncements = accountNotifications.map { $0.announcement }
            }
            .store(in: &subscriptions)

        accountNotificationsStore?.refresh()
    }

    private func listenForAnnouncements(from courses: [CDCourse]) -> AnyPublisher<[Announcement], Never> {
        let getAnnouncements = GetAnnouncementsUseCase(
            courseIds: courses.map { $0.courseID },
            activeOnly: nil,
            latestOnly: nil,
            startDate: Date.now.addYears(-1),
            endDate: Date.now
        )

        announcementsStore = environment.subscribe(getAnnouncements)

        announcementsStore?
            .statePublisher
            .subscribe(getAnnouncementsState)
            .store(in: &subscriptions)

        announcementsStore?
            .refresh()

        return announcementsStore?
            .allObjects
            .map { discussionTopics in
                discussionTopics.map { discussionTopic in
                    discussionTopic.announcement(
                        author: discussionTopic.author?.displayName ?? "",
                        courseName: courses.first { $0.courseID == discussionTopic.courseID }?.course.name
                    )
                }
            }
            .eraseToAnyPublisher() ?? Just([]).eraseToAnyPublisher()
    }

    private func listenForCourseAnnouncements(_ userID: String) {
        let getCoursesProgression = GetCoursesProgressionUseCase(userId: userID, horizonCourses: true)

        coursesProgressionStore = environment.subscribe(getCoursesProgression)

        coursesProgressionStore?
            .statePublisher
            .subscribe(coursesProgressionState)
            .store(in: &subscriptions)

        coursesProgressionStore?
            .allObjects
            .flatMap { [weak self] courses in
                guard let self = self else { return Empty<[Announcement], Never>().eraseToAnyPublisher() }
                return self.listenForAnnouncements(from: courses)
            }
            .sink { [weak self] courseAnnouncements in
                self?.courseAnnouncements = courseAnnouncements
            }
            .store(in: &subscriptions)

        coursesProgressionStore?.refresh()
    }

    private func listenForStateChanges() {
        Publishers.CombineLatest3(
            getAccountNotificationsState,
            getAnnouncementsState,
            coursesProgressionState
        )
            .sink { [weak self] accountState, announcements, coursesProgression in
                guard let self = self else { return }
                if accountState == .loading || announcements == .loading || coursesProgression == .loading {
                    self.state.accept(.loading)
                } else if accountState == .error || announcements == .error || coursesProgression == .error {
                    self.state.accept(.error)
                } else {
                    self.state.accept(.data)
                }
        }
        .store(in: &subscriptions)
    }

    private func sendAnnoucements() {
        messages.accept(announcements)
    }

    private func trySendAnnouncements() {
        if accountAnnouncements != nil && courseAnnouncements != nil {
            sendAnnoucements()
        }
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
