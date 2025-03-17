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

enum ScoresAssembly {
    static func makeView(courseID: String) -> ScoresView {
        ScoresView(
            viewModel: ScoresViewModel(
                interactor: ScoresInteractorLive(
                    courseID: courseID
                ),
                router: AppEnvironment.shared.router
            )
        )
    }

    static func makeView(viewModel: ScoresViewModel) -> ScoresView {
        ScoresView(viewModel: viewModel)
    }

    static func makeViewModel(courseID: String) -> ScoresViewModel {
        ScoresViewModel(
            interactor: ScoresInteractorLive(
                courseID: courseID
            ),
            router: AppEnvironment.shared.router
        )
    }

    static func makePreview() -> ScoresView {
        ScoresView(
            viewModel: ScoresViewModel(
                interactor: ScoresInteractorPreview(),
                router: AppEnvironment.shared.router
            )
        )
    }
}
