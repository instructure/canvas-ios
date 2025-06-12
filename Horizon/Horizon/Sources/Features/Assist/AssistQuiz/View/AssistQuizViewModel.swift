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

    // MARK: - Dependencies

    private let chatBotInteractor: AssistChatInteractor
    private var chatHistory: [AssistChatMessage] = []
    private let router: Router
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(
        chatBotInteractor: AssistChatInteractor,
        quizModel: AssistQuizModel? = nil,
        router: Router = AppEnvironment.defaultValue.router,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.chatBotInteractor = chatBotInteractor
        self.router = router
        self.scheduler = scheduler

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

        quiz = quizModel
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
        isLoaderVisible = true
        self.chatBotInteractor.publish(
            action: .chip(option: AssistChipOption(.quiz), history: chatHistory)
        )
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
        guard let quizItem = response.quizItem else {
            return
        }
        quiz = AssistQuizModel(from: quizItem)
    }
}
