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

enum AnnouncementsWidgetAssembly {
    static func makeViewModel() -> AnnouncementsListWidgetViewModel {
        AnnouncementsListWidgetViewModel(interactor: makeInteractor(), router: AppEnvironment.shared.router)
    }

    static func makeView() -> AnnouncementsListWidgetView {
        let viewModel = makeViewModel()
        return AnnouncementsListWidgetView(viewModel: viewModel)
    }

    private static func makeInteractor() -> NotificationInteractor {
        let formatter = NotificationFormatterLive()
        let interactor = NotificationInteractorLive(
            userID: AppEnvironment.shared.currentSession?.userID ?? "",
            formatter: formatter
        )
        return interactor
    }

#if DEBUG
    static func makePreview() -> AnnouncementsListWidgetView {
        let interactor = NotificationInteractorPreview()
        let viewModel = AnnouncementsListWidgetViewModel(
            interactor: interactor,
            router: AppEnvironment.shared.router
        )
        return AnnouncementsListWidgetView(viewModel: viewModel)
    }
#endif
}
