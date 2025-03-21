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
import UIKit

struct NotificationAssembly {

    static func makeView() -> UIViewController {
        let environment = AppEnvironment.shared
        let showTabBarAndNavigationBar: (Bool) -> Void = { isVisible in
            environment.tabBar(isVisible: isVisible)
            environment.navigationBar(isVisible: isVisible)
        }
        let userID = AppEnvironment.shared.currentSession?.userID ?? ""
        let formatter = NotificationFormatterLive()
        let interactor = NotificationInteractorLive(
            userID: userID,
            formatter: formatter
        )
        let viewModel = HNotificationViewModel(interactor: interactor)
        let view = HNotificationView(
            viewModel: viewModel,
            onShowNavigationBarAndTabBar: showTabBarAndNavigationBar
        )
        return CoreHostingController(view)
    }

#if DEBUG
    static func makePreview() -> HNotificationView {
        let interactor = NotificationInteractorPreview()
        let viewModel = HNotificationViewModel(interactor: interactor)
        let view = HNotificationView(viewModel: viewModel, onShowNavigationBarAndTabBar: { _ in })
        return view
    }
#endif
}
