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

enum CourseCardsAssembly {
    static func makeCourseCardsInteractor() -> CourseCardsInteractor {
        CourseCardsInteractorLive()
    }

    static func makeViewModel() -> CourseCardsViewModel {
        let onTapProgram: (ProgramSwitcherModel?, WeakViewController) -> Void = { program, viewController in
            AppEnvironment.shared.switchToLearnTab(with: program, from: viewController)
        }
        return CourseCardsViewModel(
            courseCardsInteractor: makeCourseCardsInteractor(),
            programInteractor: ProgramInteractorLive(programCourseInteractor: ProgramCourseInteractorLive()),
            router: AppEnvironment.shared.router,
            onTapProgram: onTapProgram
        )
    }

    static func makeView() -> CourseCardsView {
        CourseCardsView(viewModel: makeViewModel())
    }

    #if DEBUG
        static func makePreview() -> CourseCardsView {
            CourseCardsView(viewModel: CourseCardsViewModel(
                courseCardsInteractor: CourseCardsInteractorPreview(),
                programInteractor: ProgramInteractorPreview(),
                router: AppEnvironment.shared.router,
                onTapProgram: { _, _ in }
            ))
        }
    #endif
}
