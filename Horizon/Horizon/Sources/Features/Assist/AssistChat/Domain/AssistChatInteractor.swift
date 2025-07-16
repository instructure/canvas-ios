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

import Combine
import CombineExt
import Core
import Foundation

protocol AssistChatInteractor {
    var listen: AnyPublisher<AssistChatInteractorLive.State, Never> { get }
    func publish(action: AssistChatAction)
    func setInitialState()
}

final class AssistChatInteractorLive: AssistChatInteractor {
    enum State {
        case success(AssistChatResponse)
        case failure(Error)
    }

    // MARK: - Private

    private let actionPublisher = CurrentValueRelay<AssistChatAction?>(nil)
    private var assistDataEnvironment: AssistDataEnvironment = AssistDataEnvironment()
    private var assistDateEnvironmentOriginal: AssistDataEnvironment = AssistDataEnvironment()
    private var goalCancellable: AnyCancellable?
    private let downloadFileInteractor: DownloadFileInteractor?
    private let responsePublisher = PassthroughSubject<AssistChatInteractorLive.State, Never>()
    private var subscriptions = Set<AnyCancellable>()
    private var goals: [HGoal]

    // MARK: - init
    init(
        courseID: String? = nil,
        fileID: String? = nil,
        pageURL: String? = nil,
        downloadFileInteractor: DownloadFileInteractor? = nil
    ) {
        self.downloadFileInteractor = downloadFileInteractor
        self.assistDataEnvironment = .init(
            courseID: courseID,
            fileID: fileID,
            pageURL: pageURL
        )
        self.goals = AssistChatInteractorLive.initializeGoals(
            assistDataEnvironment: assistDataEnvironment,
            downloadFileInteractor: downloadFileInteractor
        )
        self.assistDateEnvironmentOriginal = assistDataEnvironment.duplicate()
    }

    private static func initializeGoals(
        assistDataEnvironment: AssistDataEnvironment,
        downloadFileInteractor: DownloadFileInteractor?
    ) -> [HGoal] {
        // order matters
        [
            downloadFileInteractor.map {
                HCourseDocumentGoal(
                    environment: assistDataEnvironment,
                    downloadFileInteractor: $0
                )
            },
            HCoursePageGoal(environment: assistDataEnvironment),
            HSelectCourseActionGoal(environment: assistDataEnvironment),
            HSelectCourseGoal(environment: assistDataEnvironment)
        ].compactMap { $0 }
    }

    // MARK: - Inputs

    /// Publishes a new user action to the interactor
    func publish(action: AssistChatAction) {
        var prompt: String?
        var history: [AssistChatMessage] = []

        switch action {
        case .chat(let message, let chatHistory):
            prompt = message
            history = chatHistory
        case .chip(let option, let chatHistory):
            prompt = option.prompt
            history = chatHistory
        default:
            break
        }

        if let prompt = prompt {
            let message: AssistChatMessage = .init(userResponse: prompt)
            let response: AssistChatResponse = .init(message, chatHistory: history, isLoading: true)
            responsePublisher.send(.success(response))
            history = response.chatHistory
        }

        goalCancellable = executeNextGoal(prompt: prompt, history: history)?.sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] assistChatResponse in
                guard let assistChatResponse = assistChatResponse else {
                    self?.publish(action: .chat(history: history))
                    return
                }
                let response: AssistChatResponse = .init(assistChatResponse, chatHistory: history)
                self?.responsePublisher.send(.success(response))
            }
        )
    }

    /// Subscribe to the responses from the interactor
    var listen: AnyPublisher<AssistChatInteractorLive.State, Never> {
        responsePublisher.eraseToAnyPublisher()
    }

    func setInitialState() {
        goalCancellable?.cancel()
        self.assistDataEnvironment = self.assistDateEnvironmentOriginal.duplicate()
        self.goals = AssistChatInteractorLive.initializeGoals(
            assistDataEnvironment: assistDataEnvironment,
            downloadFileInteractor: downloadFileInteractor
        )
        publish(action: .begin)
    }

    // MARK: - Private

    private func executeNextGoal(
        prompt: String? = nil,
        history: [AssistChatMessage] = []
    ) -> AnyPublisher<AssistChatMessage?, any Error>? {
        guard let goal = goals.first(where: { $0.isRequested() }) else {
            return nil
        }
        return goal.execute(response: prompt, history: history)
    }

    /// Fetches the user's short name
    private var userShortNamePublisher: AnyPublisher<String, Error> {
        ReactiveStore(useCase: GetUserProfile())
            .getEntities()
            .map { $0.first?.shortName ?? String(localized: "Learner", bundle: .horizon) }
            .eraseToAnyPublisher()
    }
}

// MARK: - Extensions

private extension String {
    func toChipOptions() -> [AssistChipOption] {
        guard let data = self.data(using: .utf8) else {
            return []
        }

        do {
            let chipOptions = try JSONDecoder().decode([AssistChipOption].self, from: data)
            return chipOptions
        } catch {
            return []
        }
    }
}

struct AssistChatInteractorPreview: AssistChatInteractor {
    var hasAssistChipOptions: Bool = true

    func publish(action: AssistChatAction) {}
    var listen: AnyPublisher<AssistChatInteractorLive.State, Never> = Just(
        .success(
            AssistChatResponse(
                AssistChatMessage(
                    quizItems: [
                        .init(
                            question: "What is the capital of France?",
                            answers: ["Paris", "London", "Berlin", "Madrid"],
                            correctAnswerIndex: 0
                        )
                    ]
                ),
                chatHistory: []
            )
        )
    )
    .eraseToAnyPublisher()

    func setInitialState() {}
}
