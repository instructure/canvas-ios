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
import Combine
import UIKit

enum LearningLibraryAssembly {
    static private func makeViewModel(
        pageType: LearningLibraryDetailsViewModel.PageType,
        didSendEvent: PassthroughSubject<Void,Never>
    ) -> LearningLibraryDetailsViewModel {
        let router = AppEnvironment.shared.router
        return LearningLibraryDetailsViewModel(
            interactor: LearningLibraryInteractorLive(),
            router: router,
            didSendEvent: didSendEvent,
            pageType: pageType
        )
    }

    static func makeView(
        pageType: LearningLibraryDetailsViewModel.PageType,
        didSendEvent: PassthroughSubject<Void,Never>
    ) -> LearningLibraryDetailsView {
        .init(viewModel: makeViewModel(pageType: pageType, didSendEvent: didSendEvent))
    }

    static func makeViewController(
        pageType: LearningLibraryDetailsViewModel.PageType,
        didSendEvent: PassthroughSubject<Void,Never>
    ) -> UIViewController {
        CoreHostingController(makeView(pageType: pageType, didSendEvent: didSendEvent))
    }

    #if DEBUG
    static func preview() -> LearningLibraryDetailsView {
        LearningLibraryDetailsView(
            viewModel: .init(
                interactor: LearningLibraryInteractorPreview(),
                router: AppEnvironment.shared.router,
                didSendEvent: PassthroughSubject<Void, Never>(),
                pageType: .bookmarks
            )
        )
    }
    #endif
}
