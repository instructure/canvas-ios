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

enum ChipOption {
    case summarize
    case keyTakeaways
    case tellMeMore
    case flashcards
    case quiz

    // swiftlint:disable line_length
    func prompt(userShortName: String, context: AIContext) -> String {
        let introduction = "You can address me as \(userShortName)."
        switch self {
        case .summarize:
            return "\(introduction) Give me a 1-2 paragraph summary of the content; don't use any information besides the provided content. Return the response as HTML paragraphs. \(context.promptContextString)"
        case .keyTakeaways:
            return "\(introduction) Give some key takeaways from this content; don't use any information besides the provided content. Return the response as an HTML unordered list. \(context.promptContextString)"
        case .tellMeMore:
            return "\(introduction) In 1-2 paragraphs, tell me more about this content. Return the response as HTML paragraphs. \(context.promptContextString)"
        case .flashcards:
            return "\(introduction) Here is the content from a course in html format, i need 7 questions with answers, like a quiz, based on the content, give back in jason format like: {data: [{question: '', answer: ''}, {question: '', answer: ''}, ...]} without any further description or text. \(context.promptContextString)"
        case .quiz:
            return "\(introduction). \(context.promptContextString)"
        }
    }
    // swiftlint:enable line_length
}

enum AIContext {
    case chat(
        prompt: String = "",
        history: [ChatMessage] = []
    ) // the user is chatting with the bot

    case chipFile(
        chipOption: ChipOption,
        file: File,
        history: [ChatMessage] = []
    ) // the user has selected a chip while viewing a file

    case chipPage(
        chipOption: ChipOption,
        title: String,
        body: String,
        history: [ChatMessage] = []
    ) // the user has selected a chip while viewing a page

    case file(
        prompt: String,
        file: File,
        history: [ChatMessage] = []
    ) // the user is being shown a document (pdf, docx, etc)

    case page(
        prompt: String,
        title: String,
        body: String,
        history: [ChatMessage] = []
    ) // the user is reading a page and types in a prompt

    // MARK: - Public

    func chipOptions() -> [ChipOption] {
        switch self {
        case .page:
            return [.summarize, .keyTakeaways, .tellMeMore, .flashcards, .quiz]
        case .file:
            return [.summarize, .keyTakeaways, .tellMeMore, .flashcards]
        default:
            return []
        }
    }

    var promptContextString: String {
        switch self {
        case .page( _, let title, let body, _),
             .chipPage(_, let title, let body, _):
            return "This is the content the user is viewing. It includes a title and a body. Title: \(title) Body: \(body)"
        default:
             return ""
        }
    }
}

struct ChatMessage {
    let text: String
    let isBot: Bool
}

struct ChatBotResponse {
    let chipOptions: [ChipOption]?
    let chatHistory: [ChatMessage]
    let flashCards: [FlashCard.FlashCard]?
    let quizItems: [QuizItem]?

    init(chipOptions: [ChipOption] = [], chatHistory: [ChatMessage] = []) {
        self.chipOptions = chipOptions
        self.chatHistory = chatHistory

        self.flashCards = nil
        self.quizItems = nil
    }

    init(flashCards: [FlashCard.FlashCard], chatHistory: [ChatMessage]) {
        self.flashCards = flashCards
        self.chatHistory = chatHistory

        self.chipOptions = nil
        self.quizItems = nil
    }

    init(quizItems: [QuizItem], chatHistory: [ChatMessage]) {
        self.chatHistory = chatHistory
        self.quizItems = quizItems

        self.chipOptions = nil
        self.flashCards = nil
    }

    var response: String? {
        chatHistory.last?.text
    }
}

protocol ChatBotInteractor {
    var context: AIContext { get set }
    var listen: AnyPublisher<ChatBotResponse, Error> { get }
}

class ChatBotInteractorLive: ChatBotInteractor {
    // MARK: - Dependencies

    private let canvasApi: API
    private let model: AIModel
    private let horizonService: HorizonService

    // MARK: - Private

    private let contextPublisher = CurrentValueRelay<AIContext>(.chat())

    // MARK: - init

    init(
        canvasApi: API = AppEnvironment.shared.api,
        horizonService: HorizonService = .cedar,
        model: AIModel = .claude3Sonnet20240229V10
    ) {
        self.canvasApi = canvasApi
        self.horizonService = horizonService
        self.model = model
    }

    // MARK: - Inputs

    var context: AIContext {
        get {
            contextPublisher.value
        }
        set {
            contextPublisher.accept(newValue)
        }
    }

    var listen: AnyPublisher<ChatBotResponse, Error> {
        Publishers.CombineLatest(
            userShortNamePublisher,
            contextPublisher.setFailureType(to: Error.self)
        )
        .flatMap(handleContextUpdate)
        .eraseToAnyPublisher()
    }

    // MARK: - Private

    private func basicChat(prompt: String, history: [ChatMessage] = []) -> AnyPublisher<ChatBotResponse, Error> {
        JWTTokenRequest(.cedar).api(from: canvasApi)
            .flatMap { cedarApi in
                cedarApi.makeRequest(
                    CedarAnswerPromptMutation(prompt: prompt)
                )
            }
            .map { graphQlResponse, _ in graphQlResponse.data.answerPrompt }
            .compactMap { answer in
                ChatBotResponse(
                    chatHistory: history + [ChatMessage(text: answer, isBot: true)]
                )
            }
            .eraseToAnyPublisher()
    }

    private func classifierPrompt(
        prompt: String,
        userShortName: String,
        context: AIContext,
        history: [ChatMessage]
    ) -> AnyPublisher<ChatBotResponse, Error> {
        let longExplanations = ClassifierOption.allCases.map { $0.longExplanation }.joined(separator: ", ")
        let defaultOption = ClassifierOption.defaultOption.rawValue
        let shortOptions = ClassifierOption.allCases.map { $0.rawValue }.joined(separator: ", ")
        // swiftlint:disable:next line_length
        let classifierPrompt = "You are an agent designed to route a learner's question to the appropriate assistant. The possible assistants are \(longExplanations). If you're not sure, choose \(defaultOption). ALWAYS answer with a single word - either \(shortOptions). Here's the learner's question: \(prompt). \(context.promptContextString)"

        return basicChat(prompt: classifierPrompt, history: history)
            .compactMap { [weak self] chatBotResponse in
                self?.handleClassifierPromptResponse(
                    userShortName: userShortName,
                    context: context,
                    response: chatBotResponse
                )
            }
            .flatMap { $0 }
            .eraseToAnyPublisher()
    }

    private func flashcards(
        userShortName: String,
        context: AIContext,
        history: [ChatMessage] = []
    ) -> AnyPublisher<ChatBotResponse, Error> {
        basicChat(
            prompt: ChipOption.flashcards.prompt(
                userShortName: userShortName,
                context: context
            ),
            history: history
        )
        .compactMap { (chatBotResponse: ChatBotResponse) in
            chatBotResponse.response.map { response in
                ChatBotResponse(
                    flashCards: FlashCard.Data.build(from: response)?.data ?? [],
                    chatHistory: chatBotResponse.chatHistory
                )
            }
        }
        .eraseToAnyPublisher()
    }

    private func handleClassifierPromptResponse(
        userShortName: String,
        context: AIContext,
        response: ChatBotResponse
    ) -> AnyPublisher<ChatBotResponse, Error> {
        let defaultOption = ClassifierOption.defaultOption
        let classifierOption = ClassifierOption(rawValue: response.response ?? defaultOption.rawValue) ?? defaultOption
        switch classifierOption {
        case .chat:
            return advancedChat(with: response.chatHistory)
        case .flashcards:
            return flashcards(
                userShortName: userShortName,
                context: context,
                history: response.chatHistory
            )
        case .quiz:
            return quiz(
                userShortName: userShortName,
                context: context,
                history: response.chatHistory
            )
        }
    }

    private func handleContextUpdate(userShortName: String, context: AIContext) -> AnyPublisher<ChatBotResponse, Error> {
        switch context {
        case .chat(let prompt, let history),
             .page(let prompt, _, _, let history):
            return classifierPrompt(prompt: prompt, userShortName: userShortName, context: context, history: history)
        case .chipFile(let chipOption, _, let history),
             .chipPage(let chipOption, _, _, let history):
            return basicChat(prompt: chipOption.prompt(userShortName: userShortName, context: context), history: history)
        default:
            return Just(ChatBotResponse())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
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
                            chatHistory: [ChatMessage(text: $0.response, isBot: true)] + history
                        )
                    }
                }
            }
            .eraseToAnyPublisher()
    }

    private var userShortNamePublisher: AnyPublisher<String, Error> {
        ReactiveStore(useCase: GetUserProfile())
            .getEntities()
            .map { $0.first?.shortName ?? String(localized: "Learner", bundle: .horizon) }
            .eraseToAnyPublisher()
    }

    private func quiz(
        userShortName: String,
        context: AIContext,
        history: [ChatMessage]
    ) -> AnyPublisher<ChatBotResponse, Error> {
        JWTTokenRequest(.cedar)
            .api(from: canvasApi)
            .flatMap { cedarApi in
                cedarApi.makeRequest(
                    CedarGenerateQuizMutation(
                        context: ChipOption.quiz.prompt(userShortName: userShortName, context: context)
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
}

// MARK: - Enums

enum ChatBotInteractorError: Error {
    case failedToDecodeToken
    case unableToGetCedarToken
    case invalidUrl
    case unknownError
}

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
