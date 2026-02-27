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
import SwiftUI
import UIKit

@Observable
final class LearnerDashboardSettingsViewModel {
    var useNewLearnerDashboard: Bool

    private var defaults: SessionDefaults
    private let environment: AppEnvironment

    init(
        defaults: SessionDefaults,
        environment: AppEnvironment = .shared
    ) {
        self.defaults = defaults
        self.environment = environment
        self.useNewLearnerDashboard = defaults.preferNewLearnerDashboard
    }

    /// Switches from the new learner dashboard back to the classic dashboard.
    /// Sets both the preference flag and triggers the feedback flow.
    /// Note: While `preferNewLearnerDashboard` is also managed by DashboardSettingsInteractorLive,
    /// the feedback flag (`shouldShowDashboardFeedback`) is only set here to ensure it's
    /// triggered specifically when users actively switch away from the new dashboard.
    func switchToClassicDashboard(viewController: UIViewController) {
        defaults.preferNewLearnerDashboard = false
        defaults.shouldShowDashboardFeedback = true
        useNewLearnerDashboard = false

        viewController.dismiss(animated: true) {
            NotificationCenter.default.post(name: .dashboardPreferenceChanged, object: nil)
        }
    }
}
