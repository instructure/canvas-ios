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

import Core

enum LearnerDashboardAssembly {

    static func makeScreen() -> LearnerDashboardScreen {
        let snackBarViewModel = SnackBarViewModel()
        let colorInteractor = LearnerDashboardColorInteractorLive(
            defaults: AppEnvironment.shared.userDefaults ?? .fallback
        )
        let coursesInteractor = LearnerDashboardWidgetAssembly.makeCoursesInteractor()
        let systemFactory: (SystemWidgetIdentifier) -> any DashboardWidgetViewModel = { widgetId in
            widgetId.makeViewModel(snackBarViewModel: snackBarViewModel, coursesInteractor: coursesInteractor)
        }
        let editableFactory: (DashboardWidgetConfig) -> any DashboardWidgetViewModel = { config in
            config.id.makeViewModel(config: config, snackBarViewModel: snackBarViewModel, coursesInteractor: coursesInteractor)
        }
        let interactor = LearnerDashboardInteractorLive(
            systemWidgetFactory: systemFactory,
            editableWidgetFactory: editableFactory
        )
        let viewModel = LearnerDashboardViewModel(
            interactor: interactor,
            colorInteractor: colorInteractor,
            snackBarViewModel: snackBarViewModel,
            environment: .shared
        )
        return LearnerDashboardScreen(viewModel: viewModel)
    }
}
