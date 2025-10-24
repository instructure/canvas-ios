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

import Core
import CombineSchedulers
import Combine
import Observation
import Foundation

@Observable
final class AnnouncementsListWidgetViewModel {
    // MARK: - Outputs

    private(set) var state: HViewState = .loading
    private(set) var currentAnnouncement: NotificationModel = NotificationModel.mock
    private(set) var isNextButtonEnabled = false
    private(set) var isPreviousButtonEnabled = false
    private(set) var isNavigationButtonVisiable = false
    private(set) var announcements: [NotificationModel] = []
    private(set) var currentInex = 0

    // MARK: - Private Properties

    private var subscriptions = Set<AnyCancellable>()
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private var isFirstLoading = true

    // MARK: - Dependencies

    private let interactor: NotificationInteractor
    private let router: Router

    // MARK: - Init

    init(
        interactor: NotificationInteractor,
        router: Router,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.interactor = interactor
        self.router = router
        self.scheduler = scheduler
        fetchAnnouncements(ignoreCache: false)
    }

    // MARK: - Actions

    func navigateToAnnouncement(
        announcement: NotificationModel,
        viewController: WeakViewController
    ) {
        let vc = HorizonMessageDetailsAssembly.makeViewController(
            announcementID: announcement.announcementId.defaultToEmpty
        )
        router.show(vc, from: viewController)
        markAsRead(announcement: announcement)
    }

    private func markAsRead(announcement: NotificationModel) {
        interactor.markNotificationAsRead(notification: announcement)
            .replaceError(with: [])
            .flatMap { Publishers.Sequence(sequence: $0) }
            .filter { $0.type == .announcement && ($0.isRead == false ) && $0.isWithinTwoWeekLimit }
            .receive(on: scheduler)
            .collect()
            .sink { [weak self] notifications in
                guard let self else { return }
                self.handleResponse(notifications: notifications)
            }
            .store(in: &subscriptions)
    }

    func fetchAnnouncements(ignoreCache: Bool, completion: (() -> Void)? = nil) {
        if isFirstLoading {
            state = .loading
        } else if announcements.isNotEmpty {
            state = .loading
        }
        isFirstLoading = false
        interactor
            .getNotifications(ignoreCache: ignoreCache)
            .replaceError(with: [])
            .flatMap { Publishers.Sequence(sequence: $0) }
            .filter { $0.type == .announcement && ($0.isRead == false ) && $0.isWithinTwoWeekLimit }
            .collect()
            .receive(on: scheduler)
            .sink { [weak self] notifications in
                guard let self else { return }
                self.handleResponse(notifications: notifications)
                completion?()
            }
            .store(in: &subscriptions)
    }

    private func handleResponse(notifications: [NotificationModel]) {
        state = notifications.isEmpty ? .empty : .data
        announcements = notifications
        currentInex = 0
        isNavigationButtonVisiable = announcements.count > 1
        if let firstAnnouncement = notifications.first {
            currentAnnouncement = firstAnnouncement
        }
        updateButtonStates()
    }

    func goNextAnnouncement() {
        guard announcements.isNotEmpty else { return }
        currentInex = min(currentInex + 1, announcements.count - 1)
        currentAnnouncement = announcements[currentInex]
        updateButtonStates()
    }

    func goPreviousAnnouncement() {
        guard announcements.isNotEmpty else { return }
        currentInex = max(currentInex - 1, 0)
        currentAnnouncement = announcements[currentInex]
        updateButtonStates()
    }

    private func updateButtonStates() {
        guard announcements.isNotEmpty else {
            isNextButtonEnabled = false
            isPreviousButtonEnabled = false
            return
        }

        isNextButtonEnabled = currentInex < announcements.count - 1
        isPreviousButtonEnabled = currentInex > 0
    }
}
