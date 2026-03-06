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
    func loadWidgets() -> AnyPublisher<[any DashboardWidgetViewModel], Never>
}

final class LearnerDashboardInteractorLive: LearnerDashboardInteractor {
    private let userDefaults: SessionDefaults
    private let systemWidgetFactory: (SystemWidgetIdentifier) -> any DashboardWidgetViewModel
    private let editableWidgetFactory: (DashboardWidgetConfig) -> any DashboardWidgetViewModel

    init(
        userDefaults: SessionDefaults = AppEnvironment.shared.userDefaults ?? .fallback,
        systemWidgetFactory: @escaping (SystemWidgetIdentifier) -> any DashboardWidgetViewModel,
        editableWidgetFactory: @escaping (DashboardWidgetConfig) -> any DashboardWidgetViewModel
    ) {
        self.userDefaults = userDefaults
        self.systemWidgetFactory = systemWidgetFactory
        self.editableWidgetFactory = editableWidgetFactory
    }

    func loadWidgets() -> AnyPublisher<[any DashboardWidgetViewModel], Never> {
        Just(())
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .map { [userDefaults, systemWidgetFactory, editableWidgetFactory] _ in
                let systemVMs = SystemWidgetIdentifier.allCases.map { systemWidgetFactory($0) }

                let defaultConfigs = LearnerDashboardWidgetAssembly.makeDefaultEditableWidgetConfigs()
                let savedConfigs = userDefaults.learnerDashboardWidgetConfigs ?? []
                // Merge saved and default configs so that widgets added in future app versions
                // always appear even when the user already has a saved configuration.
                let mergedConfigs = defaultConfigs.map { defaultConfig in
                    savedConfigs.first { $0.id == defaultConfig.id } ?? defaultConfig
                }
                let editableConfigs = mergedConfigs
                    .filter { $0.isVisible }
                    .sorted()
                let editableVMs = editableConfigs.map { editableWidgetFactory($0) }

                return systemVMs + editableVMs
            }
            .eraseToAnyPublisher()
    }
}
