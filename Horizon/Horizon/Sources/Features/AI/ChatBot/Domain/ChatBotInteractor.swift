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

// TODO: Hook up the notebook bottom bar button
protocol ChatBotInteractor {
    func publish(action: ChatBotAction)
    var listen: AnyPublisher<ChatBotResponse, Error> { get }
}

class ChatBotInteractorLive: ChatBotInteractor {
    // MARK: - Dependencies

    private let canvasApi: API
    private let model: AIModel
    private let horizonService: HorizonService

    // MARK: - Private

    private var subscriptions = Set<AnyCancellable>()
    private let actionPublisher = CurrentValueRelay<ChatBotAction?>(nil)
    private let responsePublisher = PassthroughSubject<ChatBotResponse, Error>()

    // MARK: - init

    init(
        canvasApi: API = AppEnvironment.shared.api,
        horizonService: HorizonService = .cedar,
        model: AIModel = .claude3Sonnet20240229V10
    ) {
        self.canvasApi = canvasApi
        self.horizonService = horizonService
        self.model = model

        Publishers.CombineLatest(
            actionPublisher.setFailureType(to: Error.self),
            userShortNamePublisher
        )
        .flatMap { [weak self] action, userShortName in
            guard let self = self,
                  let action = action else {
                return Empty<ChatBotResponse, Error>(completeImmediately: true).eraseToAnyPublisher()
            }
            return self.actionHandler(action: action, userShortName: userShortName)
        }
        .sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] response in
                self?.responsePublisher.send(response)
            }
        )
        .store(in: &subscriptions)
    }

    // MARK: - Inputs

    func publish(action: ChatBotAction) {
        actionPublisher.accept(action)
    }

    var listen: AnyPublisher<ChatBotResponse, Error> {
        responsePublisher
            .eraseToAnyPublisher()
    }

    // MARK: - Private

    // TODO: What to do about a file?
    private func actionHandler(action: ChatBotAction, userShortName: String) -> AnyPublisher<ChatBotResponse, any Error> {
        switch action {
        case .chat(let prompt, _) where !prompt.isEmpty,
             .page(let prompt, _, _, _) where !prompt.isEmpty:
            return publish(
                using: action,
                with: userShortName
            )
            .flatMap { newHistory in
                self.classifier(
                    prompt: prompt,
                    userShortName: userShortName,
                    action: action,
                    history: newHistory
                )
                .flatMap { classification in
                    self.handleClassifierPromptResponse(
                        classification: classification,
                        action: action,
                        history: newHistory,
                        userShortName: userShortName
                    )
                }
            }
            .eraseToAnyPublisher()
        case .chipFile(let chipOption, _, _),
             .chipPage(let chipOption, _, _, _):
            return publish(
                using: action,
                with: userShortName
            )
            .flatMap { [weak self] newHistory in
                guard let self = self else {
                    return Empty<ChatBotResponse, Error>(completeImmediately: true).eraseToAnyPublisher()
                }
                return self.basicChat(
                    prompt:
                        chipOption.prompt(
                            action: action,
                            userShortName: userShortName
                        ),
                    history: newHistory
                )
                .map { botResponse in
                    ChatBotResponse(message: ChatMessage(botResponse: botResponse), chatHistory: newHistory)
                }
                .eraseToAnyPublisher()
            }
            .compactMap { $0 }
            .eraseToAnyPublisher()
        default:
            let chipOptions = action.chipOptions().map { chipOption in
                chipOption.prompt(action: action, userShortName: userShortName)
            }
            let message = String(localized: "How can I help today?", bundle: .horizon)
            let chatBotResponse = chipOptions.isEmpty ?
                ChatBotResponse(message: ChatMessage(botResponse: message)) :
                ChatBotResponse(chipOptions: chipOptions)

            return Just(chatBotResponse)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }

    /// publishes an updated history based on the action the user took, then returns that updated history
    private func publish(using action: ChatBotAction, with userShortName: String) -> AnyPublisher<[ChatMessage], Never> {
        var response: ChatBotResponse!
        switch action {
        case .chat(let prompt, let history),
                .page(let prompt, _, _, let history):
            response = ChatBotResponse(
                message: ChatMessage(userResponse: prompt),
                chatHistory: history
            )
        case .chipFile(let chipOption, _, let history),
                .chipPage(let chipOption, _, _, let history):
            response = ChatBotResponse(
                message: ChatMessage(
                    prompt: chipOption.prompt(action: action, userShortName: userShortName),
                    text: chipOption.rawValue
                ),
                chatHistory: history
            )
        case .file(let prompt, _, let history):
            response = ChatBotResponse(
                message: ChatMessage(userResponse: prompt),
                chatHistory: history
            )
        }

        responsePublisher.send(response)

        return Just(response.chatHistory)
            .eraseToAnyPublisher()
    }

    /// Makes a request to the cedar endpoint using the given prompt and returns an answer
    private func basicChat(prompt: String, history: [ChatMessage] = []) -> AnyPublisher<String, Error> {
        JWTTokenRequest(.cedar)
            .api(from: self.canvasApi)
            .flatMap { cedarApi in
                cedarApi.makeRequest(
                    CedarAnswerPromptMutation(prompt: prompt)
                )
            }
            .map { graphQlResponse, _ in graphQlResponse.data.answerPrompt }
            .eraseToAnyPublisher()
    }

    private func classifier(
        prompt: String,
        userShortName: String,
        action: ChatBotAction,
        history: [ChatMessage]
    ) -> AnyPublisher<String, any Error> {
        let longExplanations = ClassifierOption.allCases.map { $0.longExplanation }.joined(separator: ", ")
        let defaultOption = ClassifierOption.defaultOption.rawValue
        let shortOptions = ClassifierOption.allCases.map { $0.rawValue }.joined(separator: ", ")
        // swiftlint:disable:next line_length
        let classifierPrompt = "You are an agent designed to route a learner's question to the appropriate assistant. The possible assistants are \(longExplanations). If you're not sure, choose \(defaultOption). ALWAYS answer with a single word - either \(shortOptions). Here's the learner's question: \(prompt). \(action.promptContextString)"

        return basicChat(prompt: classifierPrompt, history: history)
    }

    // Given the classification string returned from the simpleChat,
    // act on the classification given
    private func handleClassifierPromptResponse(
        classification: String,
        action: ChatBotAction,
        history: [ChatMessage],
        userShortName: String
    ) -> AnyPublisher<ChatBotResponse, Error> {
        let defaultOption = ClassifierOption.defaultOption
        let classifierOption = ClassifierOption(rawValue: classification) ?? defaultOption
        switch classifierOption {
        case .chat:
            return advancedChat(with: history)
        case .flashcards:
            return flashcards(
                action: action,
                history: history,
                userShortName: userShortName
            )
        case .quiz:
            return quiz(
                action: action,
                history: history,
                userShortName: userShortName
            )
        }
    }

    private func advancedChat(with history: [ChatMessage]) -> AnyPublisher<ChatBotResponse, Error> {
        JWTTokenRequest(.pine)
            .api(from: canvasApi)
            .flatMap { pineApi in
                pineApi.makeRequest(
                    PineQueryMutation(messages: history.map { PineQueryMutation.MessageInput(text: $0.text, role: $0.isBot ? .Assistant : .User) })
                )
                .compactMap { documentResponse in
                    documentResponse.map {
                        ChatBotResponse(
                            message: ChatMessage(botResponse: $0.response),
                            chatHistory: history
                        )
                    }
                }
            }
            .eraseToAnyPublisher()
    }

    private func quiz(
        action: ChatBotAction,
        history: [ChatMessage],
        userShortName: String
    ) -> AnyPublisher<ChatBotResponse, Error> {
        JWTTokenRequest(.cedar)
            .api(from: canvasApi)
            .flatMap { cedarApi in
                cedarApi.makeRequest(
                    CedarGenerateQuizMutation(
                        context: ChipOption.quiz.prompt(action: action, userShortName: userShortName)
                    )
                )
                .compactMap { (quizData: CedarGenerateQuizMutation.QuizData?) in
                    quizData.map {
                        ChatBotResponse(
                            quizItems: $0.quizItems,
                            chatHistory: history
                        )
                    }
                }
            }
            .eraseToAnyPublisher()
    }

    private func flashcards(
        action: ChatBotAction,
        history: [ChatMessage] = [],
        userShortName: String
    ) -> AnyPublisher<ChatBotResponse, Error> {
        basicChat(
            prompt: ChipOption.flashcards.prompt(
                action: action,
                userShortName: userShortName
            ),
            history: history
        )
        .compactMap { response in
            ChatBotResponse(
                flashCards: FlashCard.Data.build(from: response)?.data ?? [],
                chatHistory: history
            )
        }
        .eraseToAnyPublisher()
    }

    private var userShortNamePublisher: AnyPublisher<String, Error> {
        ReactiveStore(useCase: GetUserProfile())
            .getEntities()
            .map { $0.first?.shortName ?? String(localized: "Learner", bundle: .horizon) }
            .eraseToAnyPublisher()
    }
}

// MARK: - Enums

enum ChatBotInteractorError: Error {
    case failedToDecodeToken
    case unableToGetCedarToken
    case invalidUrl
    case unknownError
}

/// When requesting classification from basic chat, these are the options asked for
enum ClassifierOption: String, CaseIterable {
    case chat
    case flashcards
    case quiz

    static var defaultOption: ClassifierOption {
        .chat
    }

    var longExplanation: String {
        switch self {
        case .chat:
            return "chat (an assistant that has access to knowledge about their current course content and structure)"
        case .flashcards:
            return "flashcards (an assistant to help learner check their understanding with flashcards"
        case .quiz:
            return "quiz (an assistant that will prepare multiple choice quiz questions to help a user check their understanding); intended for terms/definitions or memorization) "
        }
    }
}

enum AIModel: String {
    case claude3Sonnet20240229V10 = "anthropic.claude-3-sonnet-20240229-v1:0"
}

// MARK: - Extensions

extension ChatBotMessage {
    func serialize() -> String {
        text
    }
}

struct FlashCard {
    struct Data: Codable {
        let data: [FlashCard]

        static func build(from string: String?) -> Data? {
            guard let data = string?.data(using: .utf8) else {
                return nil
            }
            return try? JSONDecoder().decode(Data.self, from: data)
        }
    }

    struct FlashCard: Codable {
        let question: String
        let answer: String
    }
}

struct QuizItem {
    let question: String
    let answers: [String]
    let correctAnswerIndex: Int
}

extension CedarGenerateQuizMutation.QuizData {
    var quizItems: [QuizItem] {
        data.generateQuiz.map { QuizItem(question: $0.question, answers: $0.options, correctAnswerIndex: $0.result) }
    }
}
