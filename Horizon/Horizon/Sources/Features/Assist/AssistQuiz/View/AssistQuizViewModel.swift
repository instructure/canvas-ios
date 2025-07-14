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

import Combine
import CombineSchedulers
import Core
import Foundation
import Observation

@Observable
final class AssistQuizViewModel {
    // MARK: - Input

    var selectedAnswer: AssistQuizModel.AnswerOption?

    // MARK: - Output

    private(set) var isLoaderVisible = true
    private(set) var errorMessage: String?
    var quiz: AssistQuizModel? {
        didSet {
            if quiz == nil {
                regenerateQuiz()
            } else {
                isLoaderVisible = false
            }
        }
    }
    var didSubmitQuiz: Bool = false
    var isSubmitButtonDisabled: Bool {
        selectedAnswer == nil
    }

    // MARK: - Private

    private var currentQuizIndex: Int = 0

    // MARK: - Dependencies

    private let chatBotInteractor: AssistChatInteractor
    private var chatHistory: [AssistChatMessage] = []
    private let router: Router
    private var quizzes: [AssistQuizModel] = []
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(
        chatBotInteractor: AssistChatInteractor,
        quizzes: [AssistQuizModel],
        router: Router = AppEnvironment.defaultValue.router,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.chatBotInteractor = chatBotInteractor
        self.router = router
        self.scheduler = scheduler
        self.quizzes = quizzes

        self.chatBotInteractor
            .listen
            .receive(on: scheduler)
            .sink { [weak self] result in
                switch result {
                case .success(let message):
                    self?.onMessage(message)
                case .failure(let error):
                    self?.isLoaderVisible = false
                    self?.errorMessage = error.localizedDescription
                }
            }
        .store(in: &subscriptions)

        quiz = quizzes.first
    }

    // MARK: - Input Actions

    func isCorrect(answer: AssistQuizModel.AnswerOption) -> Bool? {
        if !didSubmitQuiz {
            return nil
        }
        guard let quiz = quiz else {
            return nil
        }
        return quiz.options.firstIndex { $0.id == answer.id } == quiz.correctAnswerIndex
    }

    func submitQuiz() {
        didSubmitQuiz = true
    }

    func regenerateQuiz() {
        didSubmitQuiz = false
        let countQuizzes = quizzes.count
        guard currentQuizIndex < countQuizzes - 1 else {
            fetchQuizzes()
            return
        }
        currentQuizIndex += 1
        quiz = quizzes[safe: currentQuizIndex]
    }

    func dismiss(controller: WeakViewController) {
        router.dismiss(controller)
    }

    func pop(controller: WeakViewController) {
        router.pop(from: controller)
    }

    // MARK: - private

    private func onMessage(_ response: AssistChatResponse) {
        chatHistory = response.chatHistory
        guard let quizItems = response.chatHistory.last?.quizItems else {
            return
        }
        let quizzes = quizItems.map { AssistQuizModel(from: $0) }
        quiz = quizzes.first
    }

    private func fetchQuizzes() {
        isLoaderVisible = true
        currentQuizIndex = 0
        chatBotInteractor.publish(
            action: .chip(option: AssistChipOption(chip: "Create a Quiz"), history: chatHistory)
        )
    }
}
