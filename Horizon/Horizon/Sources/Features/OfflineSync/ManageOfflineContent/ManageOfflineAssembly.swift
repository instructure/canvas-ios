//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
import UIKit

struct ManageOfflineAssembly {
    static func makeView() -> UIViewController {
        let env = AppEnvironment.shared
        let session = env.userDefaults ?? .fallback
        let interact = ManageOfflineContentInteractorLive(
            userID: (env.currentSession?.userID).defaultToEmpty,
            session: session
        )
        let viewModel = ManageOfflineContentViewModel(
            interactor: interact,
            router: AppEnvironment.shared.router,
            session: session,
            courseSyncInteractor: HCourseSyncInteractorLive(session: session)
        ) {
            AppEnvironment.shared.switchToTab(at: HorizonTabBarType.dashboard.index)
        }
        let view = ManageOfflineContentView(viewModel: viewModel)
        return CoreHostingController(view)
    }
}
