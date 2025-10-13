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
import Core
import Foundation
import Observation

@Observable
class DashboardViewModel {
    // MARK: - Outputs

    private(set) var state: InstUI.ScreenState = .loading
    private(set) var hasUnreadNotification = false
    private(set) var hasUnreadInboxMessage = false
    
    // MARK: - Dependencies

    private let dashboardInteractor: DashboardInteractor
    private let notificationInteractor: NotificationInteractor
    private let router: Router

    // MARK: - Private variables

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(
        dashboardInteractor: DashboardInteractor,
        notificationInteractor: NotificationInteractor,
        router: Router
    ) {
        self.dashboardInteractor = dashboardInteractor
        self.notificationInteractor = notificationInteractor
        self.router = router

        setNotificationBadge()
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
}
