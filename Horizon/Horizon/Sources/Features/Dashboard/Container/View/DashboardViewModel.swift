//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import CombineSchedulers
import Core
import Foundation
import Observation

@Observable
class DashboardViewModel {
    // MARK: - Outputs

    private(set) var hasUnreadNotification = false
    private(set) var hasUnreadInboxMessage = false
    private(set) var isOfflineSyncVisible = false
    private(set) var syncProgress: Double = 0
    private(set) var syncDownloadedSize: String = ""
    private(set) var syncTotalSize: String = ""
    private(set) var isSyncError = false

    // MARK: - Dependencies

    private let dashboardInteractor: DashboardInteractor
    private let notificationInteractor: NotificationInteractor
    private let router: Router
    private let syncInteractor: HCourseSyncInteractor
    private let scheduler: AnySchedulerOf<DispatchQueue>

    // MARK: - Private variables

    private var subscriptions = Set<AnyCancellable>()
    private var lastSyncedCourses: [OfflineCourseItem] = []

    // MARK: - Init

    init(
        dashboardInteractor: DashboardInteractor,
        notificationInteractor: NotificationInteractor,
        router: Router,
        syncInteractor: HCourseSyncInteractor,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.dashboardInteractor = dashboardInteractor
        self.notificationInteractor = notificationInteractor
        self.router = router
        self.syncInteractor = syncInteractor
        self.scheduler = scheduler

        setNotificationBadge()
        observeOfflineSync()
    }

    // MARK: - Private

    private func observeOfflineSync() {
        NotificationCenter.default.publisher(for: .OfflineSyncTriggered)
            .compactMap { $0.object as? [OfflineCourseItem] }
            .sink { [weak self] courses in
                self?.isOfflineSyncVisible = true
                self?.isSyncError = false
                self?.lastSyncedCourses = courses
                self?.syncInteractor.downloadContent(courses: courses, environment: .shared)
            }
            .store(in: &subscriptions)

        syncInteractor.progressPublisher
            .receive(on: scheduler)
            .sink { [weak self] progress in
                guard let self else { return }
                syncProgress = progress.progress
                syncDownloadedSize = progress.downloadedSize
                syncTotalSize = progress.totalSize
                if progress.isComplete {
                    self.scheduler.schedule(after: self.scheduler.now.advanced(by: .seconds(1))) {
                        self.isOfflineSyncVisible = false
                    }
                }
            }
            .store(in: &subscriptions)

        syncInteractor.errorPublisher
            .receive(on: scheduler)
            .sink { [weak self] in
                self?.isSyncError = true
            }
            .store(in: &subscriptions)
    }

    private func setNotificationBadge() {
        Publishers.Zip(
            notificationInteractor.getUnreadNotificationCount(),
            dashboardInteractor.getUnreadInboxMessageCount()
        )
        .sink { [weak self] notificationCount, inboxCount in
            self?.hasUnreadNotification = notificationCount > 0
            self?.hasUnreadInboxMessage = inboxCount > 0
            TabBarBadgeCounts.unreadActivityStreamCount = UInt(notificationCount)
            TabBarBadgeCounts.unreadMessageCount = UInt(inboxCount)
        }
        .store(in: &subscriptions)
    }

    // MARK: - Inputs

    func notebookDidTap(viewController: WeakViewController) {
        router.route(to: "/notebook", from: viewController)
    }

    func notificationsDidTap(viewController: WeakViewController) {
        router.show(NotificationAssembly.makeView(), from: viewController)
    }

    func mailDidTap(viewController: WeakViewController) {
        router.route(to: "/conversations", from: viewController)
    }

    func reloadUnreadBadges() {
        setNotificationBadge()
    }

    func retrySyncDidTap() {
        isSyncError = false
        syncInteractor.downloadContent(courses: lastSyncedCourses, environment: .shared)
    }

    func offlineSyncDidTap(viewController: WeakViewController) {
        guard !isSyncError else { return }
        let vc = HOfflineDownloadStatusAssembly.makeViewController(syncInteractor: syncInteractor)
        router.show(vc, from: viewController)
    }
}
