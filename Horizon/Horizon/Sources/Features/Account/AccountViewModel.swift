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
import Observation

@Observable
final class AccountViewModel {
    // MARK: - Outputs

    private(set) var name: String = ""
    var isShowingLogoutConfirmationAlert = false

    // MARK: - Dependencies

    private let router: Router
    private let getUserInteractor: GetUserInteractor

    // MARK: - Private properties

    public let confirmLogoutViewModel = ConfirmationAlertViewModel(
        title: String(localized: "Logout", bundle: .core),
        message: String(localized: "Are you sure you want to log out?", bundle: .core),
        cancelButtonTitle: String(localized: "No", bundle: .core),
        confirmButtonTitle: String(localized: "Yes", bundle: .core),
        isDestructive: false
    )
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(
        getUserInteractor: GetUserInteractor,
        sessionInteractor: SessionInteractor,
        router: Router = AppEnvironment.shared.router
    ) {
        self.router = router
        self.getUserInteractor = getUserInteractor

        confirmLogoutViewModel.userConfirmation()
            .sink {
                sessionInteractor.logout()
            }
            .store(in: &subscriptions)
    }

    // MARK: - Input functions

    func profileDidTap(viewController: WeakViewController) {
        if let url = URL(string: "/account/profile") {
            router.route(to: url, from: viewController)
        }
    }

    func getUserName() {
        getUserInteractor
            .getUser()
            .map { $0.name }
            .replaceError(with: "")
            .assign(to: \.name, on: self)
            .store(in: &subscriptions)
    }

    func passwordDidTap() {}

    func notificationsDidTap(viewController: WeakViewController) {
        router.route(to: "/notification-settings", from: viewController)
    }

    func advancedDidTap(viewController: WeakViewController) {
        if let url = URL(string: "/account/advanced") {
            router.route(to: url, from: viewController)
        }
    }

    func betaCommunityDidTap() {}

    func giveFeedbackDidTap(viewController: WeakViewController) {
        if let url = URL(string: "https://forms.gle/jxDp3zKYe7LxNhZHA") {
            router.route(to: url, from: viewController)
        }
    }

    func logoutDidTap() {
        isShowingLogoutConfirmationAlert = true
    }
}
