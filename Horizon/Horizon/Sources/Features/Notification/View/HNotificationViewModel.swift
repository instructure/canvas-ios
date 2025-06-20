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

import Observation
import Core
import Combine

@Observable
final class HNotificationViewModel {
    // MARK: - Outputs

    private(set) var notifications: [NotificationModel] = []
    private(set) var isLoaderVisible: Bool = true
    private(set) var isFooterVisible: Bool = false
    private(set) var isNextButtonEnabled: Bool = false
    private(set) var isPreviousButtonEnabled: Bool = false

    // MARK: - Private Properties

    private var subscriptions = Set<AnyCancellable>()
    private var paginatedNotifications: [[NotificationModel]] = [[]]
    private var totalPages = 0
    private var currentPage = 0 {
        didSet {
            isPreviousButtonEnabled = currentPage > 0
            isNextButtonEnabled = currentPage < totalPages - 1
        }
    }
    // MARK: - Dependencies

    private let interactor: NotificationInteractor
    private let router: Router

    // MARK: - Init

    init(
        interactor: NotificationInteractor,
        router: Router
    ) {
        self.interactor = interactor
        self.router = router
        fetchNotifications()
    }

    // MARK: - Input Actions

    func goNext() {
        currentPage += 1
        notifications = paginatedNotifications[safe: currentPage] ?? []
    }

    func goPrevious() {
        currentPage -= 1
        notifications = paginatedNotifications[safe: currentPage] ?? []
    }

    @MainActor
    func refresh() async {
        await withCheckedContinuation { continuation in
            interactor.getNotifications(ignoreCache: true)
                .sink { [weak self] notifications in
                    continuation.resume()
                    self?.handleResponse(notifications: notifications)
                }
                .store(in: &subscriptions)
        }
    }

    func navigeteToCourseDetails(
        notification: NotificationModel,
        viewController: WeakViewController
    ) {
        let view = LearnAssembly.makeCourseDetailsViewController(
            courseID: notification.courseID,
            enrollmentID: notification.enrollmentID,
            shoudHideTabBar: true,
            selectedTab: notification.isScoreAnnouncement ? .scores : .myProgress
        )
        router.show(view, from: viewController)
    }

    // MARK: - Private Functions

    private func fetchNotifications() {
        interactor.getNotifications(ignoreCache: false)
            .sink { [weak self] notifications in
                self?.handleResponse(notifications: notifications)
            }
            .store(in: &subscriptions)
    }

    private func handleResponse(notifications: [NotificationModel]) {
        paginatedNotifications = notifications.chunked(into: 2)
        isFooterVisible = paginatedNotifications.count > 1
        totalPages = paginatedNotifications.count
        self.notifications = paginatedNotifications.first ?? []
        currentPage = 0
        isLoaderVisible = false
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: self.count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, self.count)])
        }
    }

    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
