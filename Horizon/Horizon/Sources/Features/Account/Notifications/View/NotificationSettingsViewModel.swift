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
import Observation

@Observable
final class NotificationSettingsViewModel {
    // MARK: - Outputs

    var isMessagesEmailEnabled: Bool = false
    var isMessagesPushEnabled: Bool = false
    var isDueDatesEmailEnabled: Bool = false
    var isDueDatesPushEnabled: Bool = false
    var isScoreEmailEnabled: Bool = false
    var isScorePushEnabled: Bool = false

    // MARK: - Dependencies

    private let router: Router

    init(router: Router) {
        self.router = router
    }

    // MARK: - Inputs

    func navigateBack(viewController: WeakViewController) {
        router.pop(from: viewController)
    }
}
