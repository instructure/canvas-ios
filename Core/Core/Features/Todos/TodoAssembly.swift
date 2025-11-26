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

import SwiftUI

public struct TodoAssembly {
    public static func makeTodoListViewController(env: AppEnvironment) -> UIViewController {
        let sessionDefaults = env.userDefaults ?? SessionDefaults(sessionID: env.currentSession?.uniqueID ?? "")
        let interactor = TodoInteractorLive(env: env, sessionDefaults: sessionDefaults)
        let model = TodoListViewModel(
            interactor: interactor,
            router: env.router,
            sessionDefaults: sessionDefaults
        )
        let todoVC = CoreHostingController(TodoListScreen(viewModel: model))
        todoVC.navigationBarStyle = .global
        todoVC.navigationItem.titleView = Brand.shared.headerImageView()
        return todoVC
    }

    public static func makeTodoFilterViewController(
        sessionDefaults: SessionDefaults,
        onFiltersChanged: @escaping () -> Void
    ) -> UIViewController {
        let viewModel = TodoFilterViewModel(
            sessionDefaults: sessionDefaults,
            onFiltersChanged: onFiltersChanged
        )
        let filterScreen = TodoFilterScreen(viewModel: viewModel)
        let hostingController = CoreHostingController(filterScreen)
        return hostingController
    }

    #if DEBUG

    static func makePreviewViewController(
        interactor: TodoInteractor,
        env: AppEnvironment = PreviewEnvironment()
    ) -> UIViewController {
        let sessionDefaults = SessionDefaults(sessionID: "preview")
        let viewModel = TodoListViewModel(
            interactor: interactor,
            router: env.router,
            sessionDefaults: sessionDefaults
        )
        let screen = TodoListScreen(viewModel: viewModel)
        let hostingController = CoreHostingController(screen)
        hostingController.navigationBarStyle = .global
        hostingController.navigationItem.titleView = Brand.shared.headerImageView()
        let navigationController = CoreNavigationController(rootViewController: hostingController)
        return navigationController
    }

    #endif
}
