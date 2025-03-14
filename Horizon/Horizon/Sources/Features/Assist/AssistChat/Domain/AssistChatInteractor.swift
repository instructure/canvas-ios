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
    func publish(action: AssistChatAction)
    var listen: AnyPublisher<AssistChatResponse, Error> { get }
}

class AssistChatInteractorLive: AssistChatInteractor {
    // MARK: - Dependencies

    private let canvasApi: API

    // MARK: - Private

    private let actionPublisher = CurrentValueRelay<AssistChatAction?>(nil)
    private let downloadFileInteractor: DownloadFileInteractor?
    private let localURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    private let responsePublisher = PassthroughSubject<AssistChatResponse, Error>()
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - init

    convenience init(courseId: String, pageUrl: String, canvasApi: API = AppEnvironment.shared.api) {
        let pageContextPublisher = ReactiveStore(
            useCase: GetPage(context: .course(courseId), url: pageUrl)
        )
        .getEntities()
        .map { AssistChatPageContext(title: $0.first?.title ?? "", body: $0.first?.body ?? "") }
        .eraseToAnyPublisher()

        self.init(
            pageContextPublisher: pageContextPublisher,
            canvasApi: canvasApi
        )
    }

    convenience init(
        courseId: String,
        fileId: String,
        downloadFileInteractor: DownloadFileInteractor,
        canvasApi: API = AppEnvironment.shared.api
    ) {
        let base64FileContextPublisher = ReactiveStore(useCase: GetFile(context: .course(courseId), fileID: fileId))
            .getEntities()
            .map { files in files.first }
            .flatMap { (file: File?) in
                guard let file = file,
                    let format = Format.from(mimeType: file.contentType)
                else {
                    // no reason to download the file if we can't determine the format
                    return Just(AssistChatPageContext()).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
                return
                    downloadFileInteractor
                    .download(fileID: fileId)
                    .map { try? Data(contentsOf: $0) }
                    .map { $0?.base64EncodedString() }
                    .map { (base64String: String?) in
                        guard let base64String = base64String else {
                            return AssistChatPageContext()
                        }
                        return AssistChatPageContext(
                            format: format,
                            name: file.filename,
                            source: base64String
                        )
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        self.init(
            pageContextPublisher: base64FileContextPublisher,
            canvasApi: canvasApi,
            downloadFileInteractor: downloadFileInteractor
        )
    }

    init(
        pageContextPublisher: AnyPublisher<AssistChatPageContext, Error>? = nil,
        canvasApi: API = AppEnvironment.shared.api,
        downloadFileInteractor: DownloadFileInteractor? = nil
    ) {
        self.canvasApi = canvasApi
        self.downloadFileInteractor = downloadFileInteractor

        Publishers.CombineLatest3(
            actionPublisher.setFailureType(to: Error.self),
            pageContextPublisher ?? Just(AssistChatPageContext()).setFailureType(to: Error.self).eraseToAnyPublisher(),
            userShortNamePublisher
        )
        .flatMap { [weak self] action, pageContext, userShortName in
            guard let self = self,
                let action = action
            else {
                return Empty<AssistChatResponse, Error>(completeImmediately: true).eraseToAnyPublisher()
            }
            return self.actionHandler(
                action: action,
                pageContext: pageContext,
                userShortName: userShortName
            )
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

    func publish(action: AssistChatAction) {
        actionPublisher.accept(action)
    }

    var listen: AnyPublisher<AssistChatResponse, Error> {
        responsePublisher
            .eraseToAnyPublisher()
    }

    // MARK: - Private

    private func actionHandler(
        action: AssistChatAction,
        pageContext: AssistChatPageContext,
        userShortName: String
    ) -> AnyPublisher<AssistChatResponse, any Error> {
        var prompt: String!
        var useAdvancedChat = true

        switch action {
        case .chat(let message, _):
            prompt = message
        case .chip(let option, _):
            prompt = option.prompt
            useAdvancedChat = false
        }

        if prompt.isEmpty {
            let options = pageContext.chips.map { option in
                AssistChipOption(
                    option,
                    userShortName: userShortName
                )
            }
            let message = String(localized: "How can I help today?", bundle: .horizon)
            let chatBotResponse =
                options.isEmpty
                ? AssistChatResponse(message: AssistChatMessage(prompt: nil, text: message, role: .Assistant))
                : AssistChatResponse(chipOptions: options)

            return Just(chatBotResponse)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        return publish(using: action, with: userShortName)
            .flatMap { newHistory in
                self.classifier(
                    prompt: prompt,
                    pageContext: pageContext,
                    userShortName: userShortName,
                    action: action,
                    history: newHistory
                )
                .flatMap { classification in
                    self.handleClassifierPromptResponse(
                        classification: classification,
                        action: action,
                        pageContext: pageContext,
                        history: newHistory,
                        userShortName: userShortName,
                        useAdvancedChat: useAdvancedChat
                    )
                }
            }
            .eraseToAnyPublisher()
    }

    /// publishes an updated history based on the action the user took, then returns that updated history
    private func publish(using action: AssistChatAction, with userShortName: String) -> AnyPublisher<[AssistChatMessage], Never> {
        var response: AssistChatResponse!
        switch action {
        case .chat(let prompt, let history):
            response = AssistChatResponse(
                message: AssistChatMessage(userResponse: prompt),
                chatHistory: history,
                isLoading: true
            )
        case .chip(let option, let history):
            response = AssistChatResponse(
                message: AssistChatMessage(
                    prompt: option.prompt,
                    text: option.chip
                ),
                chatHistory: history,
                isLoading: true
            )
        }

        responsePublisher.send(response)

        return Just(response.chatHistory)
            .eraseToAnyPublisher()
    }

    /// Makes a request to the cedar endpoint using the given prompt and returns an answer
    private func basicChat(
        prompt: String,
        pageContext: AssistChatPageContext? = nil
    ) -> AnyPublisher<String, Error> {
        JWTTokenRequest(.cedar)
            .api(from: self.canvasApi)
            .flatMap { [weak self] cedarApi in
                cedarApi.makeRequest(
                    CedarAnswerPromptMutation(
                        prompt: prompt,
                        document: self?.buildDocumentBlock(pageContext: pageContext)
                    )
                )
            }
            .map { graphQlResponse, _ in graphQlResponse.data.answerPrompt }
            .eraseToAnyPublisher()
    }

    private func buildDocumentBlock(pageContext: AssistChatPageContext?) -> CedarAnswerPromptMutation.DocumentBlock? {
        guard let pageContext = pageContext,
            let documentFormat = pageContext.format,
            let source = pageContext.source
        else {
            return nil
        }
        return CedarAnswerPromptMutation.DocumentBlock(
            format: documentFormat,
            base64Source: source
        )
    }

    private func chipGenerator(history: [AssistChatMessage], pageContext: AssistChatPageContext) -> AnyPublisher<[AssistChipOption], Error> {
        // swiftlint:disable line_length
        let prompt = """
                You are an agent designed to prepare potential quick response chips to show in a Learning Management System app based on an assistant agent's conversation with a learner. I'll provide you with the message history from the learner and the assistant. Create 1-3 quick response chips based off how you think the learner might want to continue the conversation. We only want to show useful response chips, so don't feel obligated to produce 3. Answer in JSON with this format: [{chip: "", prompt: ""}, {chip: "", prompt: ""}, ...]. The chip should be a 1-2 word description of the follow-up. Some good examples are \"summarize\", \"key takeaways\", \"tell me more\", \"flashcards\", or \"quiz\". Do not include chips that have been chosen previously in the chat. The prompt is the full prompt to send back to the conversation agent if the learner taps on the chip. Do not include anything in your response that is not JSON. For instance, do not return, \"Here are 3 potential quick response chips based on the conversation:\". Here's the chat history in JSON: \(history.json).
            """
        // swiftlint:enable line_length

        return basicChat(prompt: prompt, pageContext: pageContext)
            .map(toChipOptions)
            .eraseToAnyPublisher()
    }

    private func toChipOptions(_ responseJson: String) -> [AssistChipOption] {
        guard let data = responseJson.data(using: .utf8) else {
            return []
        }

        do {
            let chipOptions = try JSONDecoder().decode([AssistChipOption].self, from: data)
            return chipOptions
        } catch {
            return []
        }
    }

    private func classifier(
        prompt: String,
        pageContext: AssistChatPageContext,
        userShortName: String,
        action: AssistChatAction,
        history: [AssistChatMessage]
    ) -> AnyPublisher<String, any Error> {
        let longExplanations = ClassifierOption.allCases.map { $0.longExplanation }.joined(separator: ", ")
        let defaultOption = ClassifierOption.defaultOption.rawValue
        let shortOptions = ClassifierOption.allCases.map { $0.rawValue }.joined(separator: ", ")

        // swiftlint:disable line_length
        let classifierPrompt =
            "You are an agent designed to route a learner's question to the appropriate assistant. The possible assistants are \(longExplanations). If you're not sure, choose \(defaultOption). ALWAYS answer with a single word - either \(shortOptions). Here's the learner's question: \(prompt). Here is our chat history in JSON: \(history.json)"
        // swiftlint:enable line_length

        return basicChat(prompt: classifierPrompt, pageContext: pageContext)
    }

    // Given the classification string returned from the simpleChat,
    // act on the classification given
    private func handleClassifierPromptResponse(
        classification: String,
        action: AssistChatAction,
        pageContext: AssistChatPageContext,
        history: [AssistChatMessage],
        userShortName: String,
        useAdvancedChat: Bool = true
    ) -> AnyPublisher<AssistChatResponse, Error> {
        let defaultOption = ClassifierOption.defaultOption
        let classifierOption = ClassifierOption(rawValue: classification) ?? defaultOption
        switch classifierOption {
        case .chat:
            let chatMethod =
                useAdvancedChat
                ? advancedChat(history: history)
                : basicChat(prompt: "\(history.json) \(pageContext.prompt ?? "")", pageContext: pageContext)
            return
                chatMethod
                .map { AssistChatResponse(message: AssistChatMessage(botResponse: $0), chatHistory: history) }
                .flatMap { [weak self] response in
                    guard let self = self else {
                        return Empty<AssistChatResponse, Error>(completeImmediately: true).eraseToAnyPublisher()
                    }
                    return self.chipGenerator(history: response.chatHistory, pageContext: pageContext)
                        .map { chipOptions in
                            AssistChatResponse(
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
                pageContext: pageContext,
                history: history,
                userShortName: userShortName
            )
        case .quiz:
            return quiz(
                action: action,
                pageContext: pageContext,
                history: history,
                userShortName: userShortName
            )
        }
    }

    private func advancedChat(history: [AssistChatMessage]) -> AnyPublisher<String, Error> {
        JWTTokenRequest(.pine)
            .api(from: canvasApi)
            .flatMap { pineApi in
                pineApi.makeRequest(
                    PineQueryMutation(
                        messages: history.reversed().filter { $0.prompt != nil }.map {
                            PineQueryMutation.APIMessageInput(
                                text: $0.prompt ?? "", role: $0.role == .Assistant ? .Assistant : .User)
                        }
                    )
                )
                .compactMap { ragData in
                    ragData.map { $0.data.query.response }
                }
            }
            .eraseToAnyPublisher()
    }

    private func quiz(
        action: AssistChatAction,
        pageContext: AssistChatPageContext,
        history: [AssistChatMessage],
        userShortName: String
    ) -> AnyPublisher<AssistChatResponse, Error> {
        JWTTokenRequest(.cedar)
            .api(from: canvasApi)
            .flatMap { cedarApi in
                // swiftlint:disable line_length
                let prompt =
                    "\(pageContext.prompt ?? "You may choose the topic. Once you've selected a topic, keep to that topic using the chat history as reference."). Do not reuse questions. Do not mention the chat history in your response. Here is the chat history in JSON: \(history.json)"
                // swiftlint:enable line_length
                return cedarApi.makeRequest(
                    CedarGenerateQuizMutation(context: prompt)
                )
                .compactMap { (quizOutput: CedarGenerateQuizMutation.QuizOutput?) in
                    quizOutput.map { quizOutput in
                        guard let quizItem = quizOutput.quizItems.first else {
                            return AssistChatResponse(
                                message: AssistChatMessage(
                                    botResponse: "Sorry, I'm unable to generate a quiz for you at this time."),
                                chatHistory: history
                            )
                        }
                        return AssistChatResponse(
                            quizItem: quizItem,
                            chatHistory: history
                        )
                    }
                }
            }
            .eraseToAnyPublisher()
    }

    private func flashcards(
        action: AssistChatAction,
        pageContext: AssistChatPageContext,
        history: [AssistChatMessage] = [],
        userShortName: String
    ) -> AnyPublisher<AssistChatResponse, Error> {
        let chipPrompt = AssistChipOption(AssistChipOption.Default.flashcards, userShortName: userShortName).prompt
        let pageContextPrompt = pageContext.prompt ?? ""
        let prompt = "\(chipPrompt) \(pageContextPrompt) \(history.json)"
        return basicChat(
            prompt: prompt,
            pageContext: pageContext
        )
        .compactMap { response in
            AssistChatResponse(
                flashCards: FlashCard.build(from: response) ?? [],
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
            // swiftlint:disable line_length
            return
                "quiz (an assistant that will prepare multiple choice quiz questions to help a user check their understanding); intended for terms/definitions or memorization). You should only respond with this if they are asking for a quiz."
            // swiftlint:enable line_length
        }
    }
}

// MARK: - Extensions

struct FlashCard {
    static func build(from string: String?) -> [FlashCard]? {
        guard let data = string?.data(using: .utf8) else {
            return nil
        }
        let flashCards = try? JSONDecoder().decode([FlashCard].self, from: data)
        return flashCards
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

extension CedarGenerateQuizMutation.QuizOutput {
    var quizItems: [QuizItem] {
        data.generateQuiz.map { QuizItem(question: $0.question, answers: $0.options, correctAnswerIndex: $0.result) }
    }
}

extension Array where Element == AssistChatMessage {
    var json: String {
        guard let encoded = try? JSONEncoder().encode(self) else {
            return "[]"
        }
        return String(data: encoded, encoding: .utf8) ?? "[]"
    }
}

enum Format: String, Codable, CaseIterable {
    case pdf
    case csv
    case docx
    case doc
    case xlsx
    case xls
    case html
    case txt
    case md

    static func from(mimeType: String?) -> Format? {
        [
            "text/plain": Format.txt,
            "text/html": Format.html,
            "text/csv": Format.csv,
            "application/pdf": Format.pdf,
            "application/msword": Format.doc,
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document": Format.docx,
            "application/vnd.ms-excel": Format.xls,
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet": Format.xlsx
        ][mimeType ?? ""]
    }
}
