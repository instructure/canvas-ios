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

class AssistChatInteractor {
    var listen: AnyPublisher<State, any Error> { Empty().eraseToAnyPublisher() }
    func publish(prompt: String? = nil, history: [AssistChatMessage] = []) { }
    func setInitialState() { }

    enum State {
        case success(AssistChatResponse)
        case failure(Error)
    }

    enum AssetType: String, Codable {
        case File
        case Unknown
        case Page
    }
}

final class AssistChatInteractorLive: AssistChatInteractor {

    // MARK: - Private
    private let cedar: DomainService
    private var state: AssistState = .init()
    private var originalState: AssistState = .init()
    private var goalCancellable: AnyCancellable?
    private let responsePublisher = PassthroughSubject<AssistChatInteractorLive.State, Error>()
    private var subscriptions = Set<AnyCancellable>()
    private var tools: [any AssistTool]

    // MARK: - Init
    init(
        courseID: String? = nil,
        pageURL: String? = nil,
        fileID: String? = nil,
        textSelection: String? = nil,
        cedar: DomainService = .init(.cedar)
    ) {
        self.state = .init(
            courseID: courseID,
            fileID: fileID,
            pageURL: pageURL,
            textSelection: textSelection
        )
        self.tools = [
            AssistSummarizeTool(state: state),
            AssistAnswerPromptTool(promptType: .KeyTakeaways, state: state),
            AssistAnswerPromptTool(promptType: .RephraseContent, state: state),
            AssistAnswerPromptTool(promptType: .TellMeMore, state: state),
            AssistQuizTool(state: state),
            AssistFlashCardsTool(state: state),
            AssistCourseActionTool(state: state),
            AssistSelectCourseTool(state: state)
        ]
        self.originalState = state.duplicate()
        self.cedar = cedar
    }

    // MARK: - Inputs
    /// Publishes a new user action to the interactor
    override
    func publish(prompt: String? = nil, history: [AssistChatMessage] = []) {
        var history = history
        // if the user has said something, we publish it as a message
        // otherwise, we just publish that we're loading
        var response: AssistChatResponse = .init(chatHistory: history, isLoading: true)
        if let prompt = prompt, !prompt.isEmpty {
            let message: AssistChatMessage = .init(userResponse: prompt)
            response = .init(message, chatHistory: history, isLoading: true)
        }
        responsePublisher.send(.success(response))
        history = response.chatHistory

        let availableTools = tools.filter { $0.isAvailable }
        let toolOptions: [DomainService.ChooseOption] = availableTools.map {
            .init(name: $0.name, description: $0.description)
        }

        // TODO: Make sure we can cancel a request
        // TODO: If it didn't select a tool
        // TODO: If the prompt is empty
        var toolExecution: AnyPublisher<AssistChatResponse?, any Error>?
        if let firstTool = availableTools.first,
           availableTools.count == 1 {
            toolExecution = execute(tool: firstTool, prompt: prompt ?? "", history: history)
        } else if toolOptions.isNotEmpty, prompt?.isEmpty == false {
            toolExecution = cedar
                .choose(from: toolOptions, with: prompt ?? "")
                .flatMap { [weak self] choice in
                    guard let self, let choice, let firstTool = tools.first(where: { $0.name == choice.name }) else {
                        return Just<AssistChatResponse?>(nil)
                            .setFailureType(to: Error.self)
                            .eraseToAnyPublisher()
                    }
                    return self.execute(tool: firstTool, prompt: prompt ?? "", history: history)
                }
                .eraseToAnyPublisher()
        } else if toolOptions.isNotEmpty {
            toolExecution = Just<AssistChatResponse?>(
                    .init(
                        .init(chipOptions: toolOptions.map { .init(chip: $0.name) }),
                    )
                )
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        toolExecution?.sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] assistChatResponse in
                if let assistChatResponse {
                    self?.responsePublisher.send(.success(assistChatResponse))
                } else {
                    self?.publish(history: history)
                }
            }
        )
        .store(in: &subscriptions)
    }

    private func execute(
        tool: AssistTool,
        prompt: String,
        history: [AssistChatMessage]
    ) -> AnyPublisher<AssistChatResponse?, any Error> {
        tool.execute(response: prompt, history: history)
            .map { assistChatMessage in
                guard let assistChatMessage = assistChatMessage else {
                    return nil
                }
                return .init(
                    assistChatMessage,
                    chatHistory: history,
                    isLoading: assistChatMessage.role == .User
                )
            }
            .eraseToAnyPublisher()
    }

    /// Subscribe to the responses from the interactor
    override
    var listen: AnyPublisher<AssistChatInteractorLive.State, Error> {
        responsePublisher.eraseToAnyPublisher()
    }

    override
    func setInitialState() {
        goalCancellable?.cancel()
        self.state = self.originalState.duplicate()
        publish()
    }

    // MARK: - Private

    private func executeNextTool(
        prompt: String? = nil,
        history: [AssistChatMessage] = []
    ) -> AnyPublisher<AssistChatMessage?, any Error>? {
        tools.first(where: { $0.isAvailable })?
            .execute(response: prompt, history: history)
    }
}

extension AssistState {
    func duplicate() -> AssistState {
        .init(
            courseID: courseID.value,
            fileID: fileID.value,
            pageURL: pageURL.value,
            textSelection: textSelection.value
        )
    }
}

class AssistChatInteractorPreview: AssistChatInteractor {
    var hasAssistChipOptions: Bool = true

    override
    func publish(prompt: String? = nil, history: [AssistChatMessage] = []) {}

    override
    var listen: AnyPublisher<State, any Error> {
        Just(
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
    }

    override
    func setInitialState() {}
}
