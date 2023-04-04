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

import SwiftUI

public class QuizPreviewViewModel: ObservableObject {
    @Published public var state: QuizPreviewInteractorState = .loading
    public let navigationTitle = NSLocalizedString("Quiz Preview", comment: "")
    public let errorTitle = NSLocalizedString("Something Went Wrong", comment: "")
    public let errorDescription = NSLocalizedString("We couldn't load the quiz preview.\nPlease try again later.", comment: "")
    /** After the submission the top of the page is the quiz properties so we scroll down to the results. */
    public let scrollToResultsJS =
    """
        var results = document.querySelector('.quiz-submission')
        if (results) {
            results.scrollIntoView(true)
        }
    """

    private let interactor: QuizPreviewInteractor

    public init(interactor: QuizPreviewInteractor) {
        self.interactor = interactor

        interactor
            .state
            .assign(to: &$state)
    }
}
