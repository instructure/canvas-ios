//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

final class NotebookAssembly {
    static func makeCourseNoteInteractor() -> CourseNoteInteractor {
        CourseNoteInteractorLive()
    }

    static func makeViewModel(
        courseID: String? = nil,
        pageURL: String? = nil
    ) -> NotebookListViewModel {
        NotebookListViewModel(
            pageURL: pageURL,
            courseID: courseID,
            interactor: makeCourseNoteInteractor(),
            router: AppEnvironment.shared.router
        )
    }

    static func makeView(courseID: String) -> NotebookCourseView {
        let viewModel = makeViewModel(courseID: courseID)
        return NotebookCourseView(viewModel: viewModel)
    }

    static func makeViewController() -> CoreHostingController<NotebookListView> {
        let viewModel = makeViewModel()
        return CoreHostingController(NotebookListView(viewModel: viewModel))
    }

    static func makeViewController(
        courseID: String,
        pageURL: String
    ) -> CoreHostingController<NotebookModuleItemView> {
        let viewModel = makeViewModel(courseID: courseID, pageURL: pageURL)
        return CoreHostingController(NotebookModuleItemView(viewModel: viewModel))
    }
}
