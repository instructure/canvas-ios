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

enum LearnerDashboardLoadReason {
    case onStartup
    case onConfigChange
}

protocol LearnerDashboardInteractor {
    func loadEditableWidgetConfigs(loadReason: LearnerDashboardLoadReason) -> AnyPublisher<[DashboardWidgetConfig], Never>
}

final class LearnerDashboardInteractorLive: LearnerDashboardInteractor {
    private let userDefaults: SessionDefaults
    private let analytics: Analytics

    init(
        userDefaults: SessionDefaults = AppEnvironment.shared.userDefaults ?? .fallback,
        analytics: Analytics = .shared
    ) {
        self.userDefaults = userDefaults
        self.analytics = analytics
    }

    func loadEditableWidgetConfigs(loadReason: LearnerDashboardLoadReason) -> AnyPublisher<[DashboardWidgetConfig], Never> {
        Just(())
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .map { [userDefaults, analytics] _ in

                let defaultConfigs = EditableWidgetIdentifier.makeDefaultConfigs()
                let savedConfigs = userDefaults.learnerDashboardWidgetConfigs ?? []
                // Merge saved and default configs so that widgets added in future app versions
                // always appear even when the user already has a saved configuration.
                let mergedConfigs = defaultConfigs.map { defaultConfig in
                    savedConfigs.first { $0.id == defaultConfig.id } ?? defaultConfig
                }

                switch loadReason {
                case .onStartup:
                    analytics.logDashboardWidgetVisibility(DashboardWidgetVisibilityEvent(configs: mergedConfigs))
                case .onConfigChange:
                    analytics.logDashboardWidgetCustomization()
                }

                let editableConfigs = mergedConfigs
                    .filter { $0.isVisible }
                    .sorted()

                return editableConfigs
            }
            .eraseToAnyPublisher()
    }
}
