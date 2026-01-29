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
        let widgetFactory: (DashboardWidgetConfig) -> any DashboardWidgetViewModel = { config in
            LearnerDashboardWidgetAssembly.makeWidgetViewModel(
                config: config,
                snackBarViewModel: snackBarViewModel
            )
        }
        let interactor = makeInteractor(widgetViewModelFactory: widgetFactory)
        let viewModel = makeViewModel(interactor: interactor, snackBarViewModel: snackBarViewModel)
        return LearnerDashboardScreen(viewModel: viewModel)
    }

    private static func makeInteractor(
        widgetViewModelFactory: @escaping (DashboardWidgetConfig) -> any DashboardWidgetViewModel
    ) -> LearnerDashboardInteractor {
        LearnerDashboardInteractorLive(widgetViewModelFactory: widgetViewModelFactory)
    }

    private static func makeViewModel(
        interactor: LearnerDashboardInteractor,
        snackBarViewModel: SnackBarViewModel
    ) -> LearnerDashboardViewModel {
        LearnerDashboardViewModel(
            interactor: interactor,
            snackBarViewModel: snackBarViewModel
        )
    }
}
