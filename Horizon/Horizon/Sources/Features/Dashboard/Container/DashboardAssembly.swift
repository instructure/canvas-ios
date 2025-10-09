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
import Foundation

final class DashboardAssembly {
    static func makeDashboardInteractor() -> DashboardInteractor {
        DashboardInteractorLive()
    }

    static func makeGetUserInteractor() -> GetUserInteractor {
        GetUserInteractorLive()
    }

    static func makeView() -> DashboardView {
        let onTapProgram: (ProgramSwitcherModel?, WeakViewController) -> Void = { program, viewController in
            AppEnvironment.shared.switchToLearnTab(with: program, from: viewController)
        }
      return DashboardView(
            viewModel: .init(
                dashboardInteractor: makeDashboardInteractor(),
                notificationInteractor: NotificationAssembly.makeInteractor(),
                router: AppEnvironment.shared.router,
            )
        )
    }

    #if DEBUG
    static func makePreview() -> DashboardView {
        let dashboardInteractorPreview = DashboardInteractorPreview()
        let viewModel = DashboardViewModel(
            dashboardInteractor: dashboardInteractorPreview,
            notificationInteractor: NotificationInteractorPreview(),
            router: AppEnvironment.shared.router
        )
        return DashboardView(viewModel: viewModel)
    }
    #endif
}
