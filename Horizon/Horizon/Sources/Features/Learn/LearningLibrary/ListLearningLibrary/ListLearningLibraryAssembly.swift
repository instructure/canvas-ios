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

enum ListLearningLibraryAssembly {
    static private func makeViewModel() -> LearningLibraryViewModel {
        .init(
            router: AppEnvironment.shared.router,
            bookmarkManager: BookmarkManager()
        )
    }

    static func makeView() -> LearningLibraryView {
        let viewModel = makeViewModel()
        let recommendationView = LearningLibraryRecommendationAssembly.makeView(
            didSendEvent: viewModel.reloadCollections
        )
        return .init(viewModel: viewModel, recommendationListView: recommendationView)
    }

    #if DEBUG
    static func preview() -> LearningLibraryView {
        let viewModel = LearningLibraryViewModel(
            router: AppEnvironment.shared.router,
            interactor: LearningLibraryInteractorPreview()
        )
        let recommendationView = LearningLibraryRecommendationAssembly.makeView(
            didSendEvent: viewModel.reloadCollections
        )
        return LearningLibraryView(
            viewModel: viewModel,
            recommendationListView: recommendationView
        )
    }
    #endif
}
