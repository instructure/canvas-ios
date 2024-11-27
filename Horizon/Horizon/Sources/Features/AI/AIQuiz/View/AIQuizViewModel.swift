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

import Foundation
import Observation
import Core

@Observable
final class AIQuizViewModel {
    // MARK: - Input

    var selectedAnswer: QuizModel.AnswerOption?

    // MARK: - Output

    private(set) var state: InstUI.ScreenState = .data
    var quiz: QuizModel
    var didSubmitQuiz: Bool = false
    var isSubmitButtonDisabled: Bool {
        selectedAnswer == nil
    }

    // MARK: - Dependencies

    private let router: Router

    // MARK: - Init

    init(router: Router) {
        self.router = router
        quiz = QuizModel.mock[0]
    }

    // MARK: - Input Actions

    func submitQuiz() {
        guard let selectId = selectedAnswer?.id else {
            return
        }
        state = .loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.didSubmitQuiz = true
            self.state = .data
            self.quiz.validateSelectedAnswer(id: selectId)
        }
    }

    func regenerateQuiz() {
        state = .loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.state = .data
            self.quiz = QuizModel.mock.randomElement()!
            self.didSubmitQuiz = false
            self.selectedAnswer = nil
        }
    }

    func dismiss(controller: WeakViewController) {
        router.dismiss(controller)
    }
}
