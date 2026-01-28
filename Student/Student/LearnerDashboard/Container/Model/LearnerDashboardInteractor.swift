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

protocol LearnerDashboardInteractor {
    func loadWidgets() -> AnyPublisher<(fullWidth: [any DashboardWidgetViewModel], grid: [any DashboardWidgetViewModel]), Never>
}

final class LearnerDashboardInteractorLive: LearnerDashboardInteractor {
    private let userDefaults: SessionDefaults
    private let widgetViewModelFactory: (DashboardWidgetConfig) -> any DashboardWidgetViewModel

    init(
        userDefaults: SessionDefaults = AppEnvironment.shared.userDefaults ?? .fallback,
        widgetViewModelFactory: @escaping (DashboardWidgetConfig) -> any DashboardWidgetViewModel
    ) {
        self.userDefaults = userDefaults
        self.widgetViewModelFactory = widgetViewModelFactory
    }

    func loadWidgets() -> AnyPublisher<(fullWidth: [any DashboardWidgetViewModel], grid: [any DashboardWidgetViewModel]), Never> {
        Just(())
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .map { [userDefaults, widgetViewModelFactory] _ in
                let configs: [DashboardWidgetConfig]
                if let savedWidgets = userDefaults.learnerDashboardWidgetConfigs {
                    configs = savedWidgets.filter { $0.isVisible }.sorted()
                } else {
                    configs = LearnerDashboardWidgetAssembly.makeDefaultWidgetConfigs()
                }

                let viewModels = configs.map { widgetViewModelFactory($0) }
                let fullWidth = viewModels.filter { $0.isFullWidth }
                let grid = viewModels.filter { !$0.isFullWidth }

                return (fullWidth, grid)
            }
            .eraseToAnyPublisher()
    }
}
