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

enum HInboxAssembly {
    static func makeViewController() -> UIViewController {
        let userID = AppEnvironment.shared.currentSession?.userID ?? ""
        let inboxMessageInteractor = InboxMessageInteractorLive(
            env: AppEnvironment.shared,
            tabBarCountUpdater: .init(),
            messageListStateUpdater: .init()
        )

        let announcementsInteractor = NotificationInteractorLive(
            userID: userID,
            includePast: true,
            formatter: NotificationFormatterLive()
        )
        return CoreHostingController(
            HInboxView(
                viewModel: HInboxViewModel(
                    userID: userID,
                    router: AppEnvironment.shared.router,
                    inboxMessageInteractor: inboxMessageInteractor,
                    notificationInteractor: announcementsInteractor
                )
            )
        )
    }
#if DEBUG
    static func preview() -> HInboxView {
        let env = PreviewEnvironment()
        let context = env.globalDatabase.viewContext
        let messageInteractor = [InboxMessageListItem].make(count: 5, in: context)
        let viewModel = HInboxViewModel(
            userID: "userID",
            router: env.router,
            inboxMessageInteractor: InboxMessageInteractorPreview(environment: env, messages: messageInteractor),
            notificationInteractor: NotificationInteractorPreview()
        )
        return HInboxView(viewModel: viewModel)
    }
#endif
}
