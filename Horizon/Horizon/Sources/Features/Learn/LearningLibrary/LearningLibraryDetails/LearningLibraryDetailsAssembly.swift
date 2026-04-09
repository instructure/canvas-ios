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

enum LearningLibraryDetailsAssembly {

    static private func makeViewModel(
        collectionId: String,
        collectionName: String,
        didSendEvent: PassthroughSubject<Void, Never>?
    ) -> LearningLibraryDetailsViewModel {
        let router = AppEnvironment.shared.router
        return LearningLibraryDetailsViewModel(
            collectionId: collectionId,
            collectionName: collectionName,
            interactor: LearningLibraryInteractorLive(),
            router: router,
            didSendEvent: didSendEvent,
            bookmarkManager: BookmarkManager()
        )
    }

    static func makeView(
        collectionId: String,
        collectionName: String,
        didSendEvent: PassthroughSubject<Void, Never>? = nil
    ) -> LearningLibraryDetailsView {
        .init(viewModel: makeViewModel(
            collectionId: collectionId,
            collectionName: collectionName,
            didSendEvent: didSendEvent
        ))
    }

    static func makeViewController(
        collectionId: String,
        collectionName: String,
        didSendEvent: PassthroughSubject<Void, Never>
    ) -> UIViewController {
        CoreHostingController(makeView(
            collectionId: collectionId,
            collectionName: collectionName,
            didSendEvent: didSendEvent
        ))
    }

    #if DEBUG
    static func preview() -> LearningLibraryDetailsView {
        LearningLibraryDetailsView(
            viewModel: .init(
                collectionId: "123",
                collectionName: "Collection Name",
                interactor: LearningLibraryInteractorPreview(),
                router: AppEnvironment.shared.router,
                didSendEvent: PassthroughSubject<Void, Never>(),
                bookmarkManager: BookmarkManager()
            )
        )
    }
    #endif
}
