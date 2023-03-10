//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public enum QuizSubmissionListAssembly {

    public static func makeViewController(env: AppEnvironment,
                                          courseID: String,
                                          quizID: String,
                                          filter: QuizSubmissionListFilter) -> UIViewController {
        let interactor = QuizSubmissionListInteractorLive(env: env, courseID: courseID, quizID: quizID)
        let viewModel = QuizSubmissionListViewModel(router: env.router, filterValue: filter, interactor: interactor)
        let view = QuizSubmissionListView(model: viewModel)
        return CoreHostingController(view)
    }

#if DEBUG

    public static func makePreview(env: AppEnvironment,
                                   submissions: [QuizSubmissionListItem])
    -> QuizSubmissionListView {
        let interactor = QuizSubmissionListInteractorPreview(env: env, submissions: submissions)
        let viewModel = QuizSubmissionListViewModel(router: env.router, filterValue: .all, interactor: interactor)
        return QuizSubmissionListView(model: viewModel)
    }

#endif
}
