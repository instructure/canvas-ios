//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import UIKit

public enum InboxAssembly {

    public static func makeInboxViewController() -> UIViewController {
        let env = AppEnvironment.shared
        let messageInteractor = InboxMessageInteractorLive(env: env,
                                                    tabBarCountUpdater: .init(),
                                                    messageListStateUpdater: .init())
        let favouriteInteractor = InboxMessageFavouriteInteractorLive()
        let viewModel = InboxViewModel(
            messageInteractor: messageInteractor,
            favouriteInteractor: favouriteInteractor,
            router: env.router
        )

        let inboxVC = CoreHostingController(InboxView(model: viewModel))
        inboxVC.navigationItem.titleView = Core.Brand.shared.headerImageView()

        let nav = CoreNavigationController(rootViewController: inboxVC)
        nav.navigationBar.useGlobalNavStyle()
        return nav
    }

#if DEBUG

    public static func makePreview(environment: AppEnvironment,
                                   messages: [InboxMessageListItem])
    -> InboxView {
        let messageInteractor = InboxMessageInteractorPreview(environment: environment, messages: messages)
        let favouriteInteractor = InboxMessageFavouriteInteractorLive()
        let viewModel = InboxViewModel(
            messageInteractor: messageInteractor,
            favouriteInteractor: favouriteInteractor,
            router: environment.router
        )
        return InboxView(model: viewModel)
    }

#endif
}
