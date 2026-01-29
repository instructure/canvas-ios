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

enum ProgramDetailsAssembly {
    static func makeView(programID: String) -> ProgramDetailsView {
        let programCourseInteractor = ProgramCourseInteractorLive()
        let interactor = ProgramInteractorLive(programCourseInteractor: programCourseInteractor)
        let router = AppEnvironment.shared.router
        let viewModel = ProgramDetailsViewModel(
            interactor: interactor,
            learnCoursesInteractor: GetLearnCoursesInteractorLive(),
            router: router,
            programID: programID
        )
        return ProgramDetailsView(viewModel: viewModel)
    }

    static func makeViewController(programID: String) -> UIViewController {
        CoreHostingController(makeView(programID: programID))
    }
}
