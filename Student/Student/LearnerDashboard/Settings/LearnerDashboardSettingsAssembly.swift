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
import UIKit

enum LearnerDashboardSettingsAssembly {

    static func makeViewModel(
        env: AppEnvironment = .shared,
        colorInteractor: LearnerDashboardColorInteractor,
        onConfigsChanged: @escaping () -> Void
    ) -> LearnerDashboardSettingsViewModel {
        let defaults = env.userDefaults ?? .fallback
        let username = env.currentSession?.userName ?? ""
        let configs = defaults.learnerDashboardWidgetConfigs
            ?? EditableWidgetIdentifier.makeDefaultConfigs()
        let coursesAndGroupsSettingsVM = CoursesAndGroupsWidgetSettingsViewModel(env: env)
        let subSettingsViews: [EditableWidgetIdentifier: AnyView] = [
            .coursesAndGroups: AnyView(CoursesAndGroupsWidgetSettingsView(viewModel: coursesAndGroupsSettingsVM))
        ]

        let courseSettingsViewModel = LearnerDashboardCourseSettingsViewModel(
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
