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
import UIKit

@Observable
final class LearnerDashboardSettingsViewModel {
    var useNewLearnerDashboard: Bool

    let popoverSize = CGSize(width: 350, height: 250)

    private var defaults: SessionDefaults

    init(defaults: SessionDefaults) {
        self.defaults = defaults
        self.useNewLearnerDashboard = defaults.preferNewLearnerDashboard
    }

    func switchToClassicDashboard(viewController: UIViewController) {
        defaults.preferNewLearnerDashboard = false
        useNewLearnerDashboard = false

        viewController.dismiss(animated: true) {
            NotificationCenter.default.post(name: .dashboardPreferenceChanged, object: nil)
        }
    }
}
