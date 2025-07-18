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
    var listen: AnyPublisher<AssistChatInteractorLive.State, any Error> { get }
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
    private let responsePublisher = PassthroughSubject<AssistChatInteractorLive.State, Error>()
    private var subscriptions = Set<AnyCancellable>()
    private var goals: [any AssistGoal]

    // MARK: - Init
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

        // if the user said something, we publish it as a message
        // otherwise, we just publish that we're loading
        var response: AssistChatResponse = .init(chatHistory: history, isLoading: true)
        if let prompt = prompt {
            let message: AssistChatMessage = .init(userResponse: prompt)
            response = .init(message, chatHistory: history, isLoading: true)
        }
        responsePublisher.send(.success(response))
        history = response.chatHistory

        goalCancellable = executeNextGoal(prompt: prompt, history: history)?.sink(
            receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.responsePublisher.send(.failure(error))
                }
            },
            receiveValue: { [weak self] assistChatResponse in
                guard let assistChatResponse = assistChatResponse else {
                    self?.publish(action: .chat(prompt: nil, history: history))
                    return
                }
                let response: AssistChatResponse = .init(assistChatResponse, chatHistory: history)
                self?.responsePublisher.send(.success(response))
            }
        )
    }

    /// Subscribe to the responses from the interactor
    var listen: AnyPublisher<AssistChatInteractorLive.State, Error> {
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

    // MARK: - Static
    private static func initializeGoals(
        assistDataEnvironment: AssistDataEnvironment,
        downloadFileInteractor: DownloadFileInteractor?
    ) -> [any AssistGoal] {
        // order matters
        var goals = [any AssistGoal]()
        if let downloadFileInteractor = downloadFileInteractor {
            goals.append(
                AssistCourseDocumentGoal(
                    environment: assistDataEnvironment,
                    downloadFileInteractor: downloadFileInteractor
                )
            )
        }
        goals += [
            AssistCoursePageGoal(environment: assistDataEnvironment),
            AssistSelectCourseActionGoal(environment: assistDataEnvironment),
            AssistSelectCourseGoal(environment: assistDataEnvironment)
        ]
        return goals
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
}

struct AssistChatInteractorPreview: AssistChatInteractor {
    var hasAssistChipOptions: Bool = true

    func publish(action: AssistChatAction) {}
    var listen: AnyPublisher<AssistChatInteractorLive.State, any Error> = Just(
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
    .setFailureType(to: Error.self)
    .eraseToAnyPublisher()

    func setInitialState() {}
}
