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
            return publish( using: action, with: userShortName)
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
        case .chip(let option, _, _),
             .chipPage(let option, _, _, _):
            return publish(using: action, with: userShortName)
                .flatMap { [weak self] newHistory in
                    guard let self = self else {
                        return Empty<ChatBotResponse, Error>(completeImmediately: true).eraseToAnyPublisher()
                    }
                    return self.basicChat(
                        prompt: option.prompt,
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
            let options = action.defaultChipOptions.map { option in
                ChipOption(option, action: action, userShortName: userShortName)
            }
            let message = String(localized: "How can I help today?", bundle: .horizon)
            let chatBotResponse = options.isEmpty ?
                ChatBotResponse(message: ChatMessage(prompt: nil, text: message, isBot: true)) :
                ChatBotResponse(chipOptions: options)

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
                chatHistory: history,
                isLoading: true
            )
        case .chip(let option, let history, _),
                .chipPage(let option, _, _, let history):
            response = ChatBotResponse(
                message: ChatMessage(
                    prompt: option.prompt,
                    text: option.chip
                ),
                chatHistory: history,
                isLoading: true
            )
        case .file(let prompt, _, let history):
            response = ChatBotResponse(
                message: ChatMessage(userResponse: prompt),
                chatHistory: history,
                isLoading: true
            )
        }

        responsePublisher.send(response)

        return Just(response.chatHistory)
            .eraseToAnyPublisher()
    }

    // TODO: It looks like I'm not using history here. Should I be?
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

    private func chipGenerator(history: [ChatMessage]) -> AnyPublisher<[ChipOption], Error> {
        var chatHistoryJson = "[]"

        if let encoded = try? JSONEncoder().encode(history) {
            chatHistoryJson = String(data: encoded, encoding: .utf8) ?? "[]"
        }

        // swiftlint:disable:next line_length
        let prompt = """
            You are an agent designed to prepare potential quick response chips to show in a Learning Management System app based on an assistant agent's conversation with a learner. I'll provide you with the message history from the learner and the assistant. Please create 1-3 quick response chips based off how you think the learner might want to continue the conversation. We only want to show useful response chips, so don't feel obligated to produce 3. Answer in JSON with this format: [{chip: "", prompt: ""}, ...]. The chip should be a 1-2 word description of the follow-up (like "summarize", "more detail", or "explain X"), and the prompt is the full prompt to send back to the conversation agent if the learner taps on the chip. Don't include anything in the output besides the JSON. Here's the chat history in JSON: \(chatHistoryJson).
        """

        return basicChat(prompt: prompt)
            .map(toChipOptions)
            .eraseToAnyPublisher()
    }

    private func toChipOptions(_ responseJson: String) -> [ChipOption] {
        guard let data = responseJson.data(using: .utf8) else {
            return []
        }

        do {
            let chipOptions = try JSONDecoder().decode([ChipOption].self, from: data)
            return chipOptions
        } catch {
            return []
        }
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
                .flatMap { [weak self] response in
                    guard let self = self else {
                        return Empty<ChatBotResponse, Error>(completeImmediately: true).eraseToAnyPublisher()
                    }
                    return self.chipGenerator(history: response.chatHistory)
                        .map { chipOptions in
                            ChatBotResponse(
                                chipOptions: chipOptions,
                                chatHistory: response.chatHistory
                            )
                        }
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
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
                    PineQueryMutation(
                        messages: history
                            .compactMap {
                                guard let prompt = $0.prompt else { return nil }
                                return PineQueryMutation.APIMessageInput(text: prompt, role: $0.isBot ? .Assistant : .User)
                            }
                    )
                )
                .compactMap { ragData in
                    ragData.map {
                        ChatBotResponse(
                            message: ChatMessage(botResponse: $0.data.query.response),
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
                        context: ChipOption(DefaultChipOption.quiz, action: action, userShortName: userShortName).prompt
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
            prompt: ChipOption(DefaultChipOption.flashcards, action: action, userShortName: userShortName).prompt
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
