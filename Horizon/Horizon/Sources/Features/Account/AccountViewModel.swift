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
import Observation

@Observable
final class AccountViewModel {
    // MARK: - Outputs

    private(set) var name: String = ""
    private(set) var institution: String = "Generation Me"
    var isShowingLogoutConfirmationAlert = false

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
        sessionInteractor: SessionInteractor
    ) {
        getUserInteractor
            .getUser()
            .map { $0.name }
            .replaceError(with: "")
            .assign(to: \.name, on: self)
            .store(in: &subscriptions)

        confirmLogoutViewModel.userConfirmation()
            .sink {
                sessionInteractor.logout()
            }
            .store(in: &subscriptions)
    }

    // MARK: - Input functions

    func profileDidTap() {}

    func passwordDidTap() {}

    func notificationsDidTap() {}

    func advancedDidTap() {}

    func betaCommunityDidTap() {}

    func giveFeedbackDidTap() {}

    func logoutDidTap() {
        isShowingLogoutConfirmationAlert = true
    }
}
