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

import Foundation

public struct QuizPreviewAssembly {

    public static func makeQuizPreviewViewController(courseID: String,
                                                     quizID: String,
                                                     env: AppEnvironment = .shared)
    -> UIViewController {
        let interactor = QuizPreviewInteractorLive(courseID: courseID,
                                                   quizID: quizID,
                                                   env: env)
        let viewModel = QuizPreviewViewModel(interactor: interactor)
        let view = QuizPreviewView(viewModel: viewModel)
        let viewHost = CoreHostingController(view)
        viewHost.preferredStatusBarStyleOverride = { viewController in
            viewController.traitCollection.isDarkInterface ? .lightContent : .darkContent
        }

        return viewHost
    }

#if DEBUG

    public static func makePreview(state: QuizPreviewInteractorState) -> QuizPreviewView {
        let interactor = QuizPreviewInteractorPreview(state: state)
        let viewModel = QuizPreviewViewModel(interactor: interactor)
        return QuizPreviewView(viewModel: viewModel)
    }

#endif

}
