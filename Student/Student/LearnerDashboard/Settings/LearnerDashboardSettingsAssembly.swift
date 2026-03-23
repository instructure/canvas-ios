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
import SwiftUI

enum LearnerDashboardSettingsAssembly {

    static func makeViewModel(
        env: AppEnvironment = .shared,
        colorInteractor: LearnerDashboardColorInteractor,
        onConfigsChanged: @escaping () -> Void
    ) -> LearnerDashboardSettingsViewModel {
        let defaults = env.userDefaults ?? .fallback
        let username = env.currentSession?.userName ?? ""
        let defaultConfigs = EditableWidgetIdentifier.makeDefaultConfigs()
        let savedConfigs = defaults.learnerDashboardWidgetConfigs ?? []
        let configs = defaultConfigs.map { defaultConfig in
            savedConfigs.first { $0.id == defaultConfig.id } ?? defaultConfig
        }
        let subSettingsViews = EditableWidgetIdentifier.allCases.reduce(into: [EditableWidgetIdentifier: AnyView]()) { result, id in
            result[id] = id.makeSubSettingsView(env: env)
        }

        let courseSettingsViewModel = LearnerDashboardSettingsWidgetsSectionViewModel(
            userDefaults: defaults,
            configs: configs,
            username: username,
            subSettingsViews: subSettingsViews,
            onConfigsChanged: onConfigsChanged
        )

        let viewModel = LearnerDashboardSettingsViewModel(
            defaults: defaults,
            colorInteractor: colorInteractor,
            courseSettingsViewModel: courseSettingsViewModel
        )
        return viewModel
    }
}
