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
    private(set) var isSeeMoreButtonVisible: Bool = false

    // MARK: - Private Properties

    private var subscriptions = Set<AnyCancellable>()
    private var paginatedNotifications: [[NotificationModel]] = [[]]
    private var totalPages = 0
    private var currentPage = 0 {
        didSet {
            isSeeMoreButtonVisible = currentPage < totalPages - 1
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

    func seeMore() {
        currentPage += 1
        notifications.append(contentsOf: paginatedNotifications[safe: currentPage] ?? [])
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

    func navigeteToDetails(
        notification: NotificationModel,
        viewController: WeakViewController
    ) {
        switch notification.type {
        case .score, .scoreChanged, .dueDate:
            let url = (notification.type == .dueDate)
            ? notification.htmlURL
            : notification.assignmentURL
            if let url {
                router.route(to: url, from: viewController)
            } else {
                let view = LearnAssembly.makeCourseDetailsViewController(
                    courseID: notification.courseID,
                    enrollmentID: notification.enrollmentID,
                    shoudHideTabBar: true,
                    selectedTab: notification.isScoreAnnouncement ? .scores : .myProgress
                )
                router.show(view, from: viewController)
            }

        case .announcement:
            let vc = HorizonMessageDetailsAssembly.makeViewController(
                announcementID: notification.announcementId ?? ""
            )
            router.show(vc, from: viewController)
        }
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
        paginatedNotifications = notifications.chunked(into: 10)
        totalPages = paginatedNotifications.count
        self.notifications = paginatedNotifications.first ?? []
        currentPage = 0
        isLoaderVisible = false
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
