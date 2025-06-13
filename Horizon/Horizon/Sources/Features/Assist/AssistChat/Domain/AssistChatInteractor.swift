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
    var hasAssistChipOptions: Bool { get }
    var userShortNamePublisher: CurrentValueSubject<String, Never> { get }
}

class AssistChatInteractorLive: AssistChatInteractor {
    // MARK: - Dependencies

    private let cedarDomainService: DomainService
    private let downloadFileInteractor: DownloadFileInteractor?
    private let pineDomainService: DomainService
    var hasAssistChipOptions: Bool = false
    private let userID: String

    // MARK: - Private

    private let actionPublisher = CurrentValueRelay<AssistChatAction?>(nil)
    /// The ID of the course we're currently discussing
    private var courseID: String?
    private let localURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    private let pageContextPublisher: CurrentValueSubject<AssistChatPageContext, Never> = .init(AssistChatPageContext())
    private let responsePublisher = PassthroughSubject<AssistChatResponse, Error>()
    private var subscriptions = Set<AnyCancellable>()
    private var userShortName: String? {
        userShortNamePublisher.value
    }
    /// Publishes the user's short name
    let userShortNamePublisher: CurrentValueSubject<String, Never> = .init("")

    // MARK: - init

    /// Initializes the interactor when viewing a page for context
    convenience init(
        courseID: String,
        pageUrl: String,
        cedarDomainService: DomainService = DomainService(.cedar),
        pineDomainService: DomainService = DomainService(.pine)
    ) {
        self.init(
            cedarDomainService: cedarDomainService,
            pineDomainService: pineDomainService,
            courseID: courseID
        )
        hasAssistChipOptions = true

        ReactiveStore(useCase: GetPage(context: .course(courseID), url: pageUrl))
            .getEntities()
            .map { AssistChatPageContext(title: $0.first?.title ?? "", body: $0.first?.body ?? "") }
            .replaceError(with: AssistChatPageContext())
            .sink { [weak self] pageContext in
                guard let self = self else { return }
                self.pageContextPublisher.send(pageContext)
            }
            .store(in: &subscriptions)
    }

    /// Initializes the interactor when viewing a file for context
    convenience init(
        courseID: String,
        fileID: String,
        downloadFileInteractor: DownloadFileInteractor,
        cedarDomainService: DomainService = DomainService(.cedar),
        pineDomainService: DomainService = DomainService(.pine)
    ) {
        self.init(
            cedarDomainService: cedarDomainService,
            pineDomainService: pineDomainService,
            downloadFileInteractor: downloadFileInteractor,
            courseID: courseID
        )

        ReactiveStore(useCase: GetFile(context: .course(courseID), fileID: fileID))
            .getEntities()
            .map { files in files.first }
            .flatMap { (file: File?) in
                guard let file = file,
                      let format = AssistChatDocumentType.from(mimeType: file.contentType) else {
                    return Just(AssistChatPageContext()).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
                return downloadFileInteractor
                    .download(fileID: fileID)
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
            .replaceError(with: AssistChatPageContext())
            .sink { [weak self] pageContext in
                guard let self = self else { return }
                self.pageContextPublisher.send(pageContext)
            }
            .store(in: &subscriptions)
    }

    init(
        cedarDomainService: DomainService = DomainService(.cedar),
        pineDomainService: DomainService = DomainService(.pine),
        downloadFileInteractor: DownloadFileInteractor? = nil,
        userID: String = AppEnvironment.shared.currentSession?.userID ?? "",
        courseID: String? = nil
    ) {
        self.cedarDomainService = cedarDomainService
        self.pineDomainService = pineDomainService
        self.downloadFileInteractor = downloadFileInteractor
        self.userID = userID
        self.courseID = courseID

        self.listenForUserShortNameUpdates()

        userShortNamePublisher.sink { [weak self] userShortName in
            guard let self = self, !userShortName.isEmpty else { return }
            return self.pageContextPublisher.sink { [weak self] _ in
                guard let self = self else { return }
                return self.actionPublisher.flatMap { [weak self] _ in
                    guard let self = self else {
                        return Empty<AssistChatResponse, Error>(completeImmediately: true).eraseToAnyPublisher()
                    }
                    return self.actionHandler()
                }
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { [weak self] response in
                        self?.responsePublisher.send(response)
                    }
                )
                .store(in: &self.subscriptions)
            }
            .store(in: &self.subscriptions)
        }
        .store(in: &subscriptions)
    }

    // MARK: - Inputs

    /// Publishes a new user action to the interactor
    func publish(action: AssistChatAction) {
        actionPublisher.accept(action)
    }

    /// Subscribe to the responses from the interactor
    var listen: AnyPublisher<AssistChatResponse, Error> {
        responsePublisher
            .eraseToAnyPublisher()
    }

    // MARK: - Private

    /// When a new action comes in from the user, this function starts processing it
    private func actionHandler() -> AnyPublisher<AssistChatResponse, any Error> {
        guard let action: AssistChatAction = actionPublisher.value else {
            return Empty<AssistChatResponse, Error>(completeImmediately: true).eraseToAnyPublisher()
        }
        var prompt: String = ""
        var assistStaticLearnerResponse: AssistStaticLearnerResponse?
        var assistStaticBotResponse: AssistStaticBotResponse?
        var chatHistory: [AssistChatMessage] = []

        switch action {
        case .chat(_, let history):
            let last = history.last
            assistStaticBotResponse = last?.staticResponse
            prompt = last?.prompt ?? ""
            chatHistory = history
        case .chip(let option, let history):
            prompt = option.prompt ?? ""
            assistStaticLearnerResponse = option.localResponse
            if case .selectCourse(_, let courseID) = assistStaticLearnerResponse {
                self.courseID = courseID
            }
            chatHistory = history
        }

        // This should really only happen when the user first opens the chat
        if prompt.isEmpty {
            return courseSelectionResponse(chatHistory: chatHistory).eraseToAnyPublisher()
        }

        if let localResponse = assistStaticLearnerResponse {
            return Just(localResponse.assistChatResponse(chatHistory: chatHistory))
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        weak var weakSelf = self
        return publish(using: action)
            .flatMap { newHistory in
                guard let self = weakSelf else {
                    return Empty<AssistChatResponse, Error>(completeImmediately: true).eraseToAnyPublisher()
                }
                var service = self.cedarConversation(prompt: prompt, history: newHistory)
                if let courseID = self.courseID {
                    service = self.pineRAGService(
                        history: newHistory,
                        courseID: courseID
                    )
                }
                return service
                    .map {
                        AssistChatResponse(
                            assistStaticBotResponse?.responseHandler(response: $0) ?? AssistChatMessage(botResponse: $0),
                            chatHistory: newHistory
                        )
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func listenForUserShortNameUpdates() {
        ReactiveStore(useCase: GetUserProfile())
            .getEntities()
            .replaceError(with: [])
            .map { $0.first?.shortName ?? String(localized: "Learner", bundle: .horizon) }
            .sink { [weak self] userShortName in
                guard let self = self else { return }
                self.userShortNamePublisher.send(userShortName)
            }
            .store(in: &subscriptions)
    }

    /// Returns any configured chips to show based on the context. If there are none, we return a default message
    private func courseSelectionResponse(chatHistory: [AssistChatMessage]) -> AnyPublisher<AssistChatResponse, Error> {
        ReactiveStore(
            useCase: GetCoursesProgressionUseCase(userId: userID)
        )
        .getEntities()
        .map { [weak self] courses in
            if let course = courses.first(where: { $0.course.id == self?.courseID }) {
                return .courseHelp(courseName: course.course.name ?? "", chatHistory: chatHistory)
            }
            if let courseName = courses.first?.course.name, courses.count == 1 {
                return AssistChatResponse.courseHelp(courseName: courseName)
            }
            if courses.count > 1 {
                return AssistChatResponse.courseSelection(
                    courses: courses.map {
                        CourseNameAndID(
                            name: $0.course.name ?? "",
                            id: $0.courseID
                        )
                    },
                )
            }
            return AssistChatResponse(
                AssistChatMessage(
                    botResponse: String(
                        localized: "It looks like you're not enrolled in any courses yet. Please enroll in a course and come back!",
                        bundle: .horizon
                    )
                ),
                isFreeTextAvailable: false
            )
        }
        .eraseToAnyPublisher()
    }

    /// Makes a request to the cedar endpoint using the given prompt and returns an answer
    private func cedarConversation(
        prompt: String,
        history: [AssistChatMessage] = [],
    ) -> AnyPublisher<String, Error> {
        cedarDomainService.api()
            .flatMap { cedarApi in
                cedarApi.makeRequest(
                    CedarConversationMutation(
                        systemPrompt: prompt,
                        messages: history.domainServiceConversationMessages
                    )
                )
            }
            .map { $0?.data.conversation.response ?? "" }
            .eraseToAnyPublisher()
    }

    private func cedarBasicChat(
        prompt: String,
        pageContext: AssistChatPageContext = AssistChatPageContext()
    ) -> AnyPublisher<String, Error> {
        cedarDomainService.api()
            .flatMap { cedarApi in
                cedarApi.makeRequest(
                    CedarAnswerPromptMutation(
                        prompt: prompt,
                        document: CedarAnswerPromptMutation.DocumentBlock.build(from: pageContext)
                    )
                )
            }
            .map { graphQlResponse, _ in graphQlResponse.data.answerPrompt }
            .eraseToAnyPublisher()
    }

    /// Makes a request to the pine endpoint using the given history
    private func pineRAGService(history: [AssistChatMessage], courseID: String) -> AnyPublisher<String, Error> {
        pineDomainService.api()
            .flatMap { pineApi in
                pineApi.makeRequest(
                    PineQueryMutation(
                        messages: history.domainServiceConversationMessages,
                        courseID: courseID
                    )
                )
                .compactMap { ragData in
                    ragData.map { $0.data.query.response }
                }
            }
            .eraseToAnyPublisher()
    }

    /// Given the prompt, ask the AI to classify it to one of our ClassifierOptions (e.g., chat, flashcards, quiz)
    private func classifier(
        prompt: String,
        action: AssistChatAction,
        history: [AssistChatMessage]
    ) -> AnyPublisher<String, any Error> {
        let longExplanations = ClassifierOption.allCases.map { $0.longExplanation }.joined(separator: ", ")
        let defaultOption = ClassifierOption.defaultOption.rawValue
        let shortOptions = ClassifierOption.allCases.map { $0.rawValue }.joined(separator: ", ")
        let pageContext = pageContextPublisher.value

        // swiftlint:disable line_length
        let classifierPrompt =
            "You are an agent designed to route a learner's question to the appropriate assistant. The possible assistants are \(longExplanations). If you're not sure, choose \(defaultOption). ALWAYS answer with a single word - either \(shortOptions). Here's the learner's question: \(prompt). Here is our chat history in JSON: \(history.json)"
        // swiftlint:enable line_length

        return cedarBasicChat(prompt: classifierPrompt, pageContext: pageContext)
    }

    /// Calls the basic chat endpoint to generate flashcards
    private func flashcards(
        action: AssistChatAction,
        history: [AssistChatMessage] = []
    ) -> AnyPublisher<AssistChatResponse, Error> {
        let chipPrompt = AssistChipOption(AssistChipOption.Default.flashcards, userShortName: userShortName).prompt ?? ""
        let pageContext = pageContextPublisher.value
        let pageContextPrompt = pageContext.prompt ?? ""
        let prompt = "\(chipPrompt) \(pageContextPrompt) \(history.json)"
        return cedarBasicChat(
            prompt: prompt,
            pageContext: pageContext
        )
        .compactMap { response in
            AssistChatResponse(
                AssistChatMessage(flashCards: AssistChatFlashCard.build(from: response) ?? []),
                chatHistory: history
            )
        }
        .eraseToAnyPublisher()
    }

    // Given the classification string returned from the simpleChat,
    // act on the classification given
    private func handleClassifierPromptResponse(
        classification: String,
        action: AssistChatAction,
        history: [AssistChatMessage],
        courseID: String
    ) -> AnyPublisher<AssistChatResponse, Error> {
        let defaultOption = ClassifierOption.defaultOption
        let classifierOption = ClassifierOption(rawValue: classification) ?? defaultOption
        let pageContext = pageContextPublisher.value

        // only use Pine chat if we don't have a document context
        let usePineRAGService = pageContext.prompt == nil

        switch classifierOption {
        case .chat:
            let chatMethod =
                usePineRAGService
            ? pineRAGService(history: history, courseID: courseID)
                : cedarBasicChat(prompt: "\(history.json) \(pageContext.prompt ?? "")", pageContext: pageContext)
            return
                chatMethod
                .map { AssistChatResponse(AssistChatMessage(botResponse: $0), chatHistory: history) }
                .eraseToAnyPublisher()
        case .flashcards:
            return flashcards(
                action: action,
                history: history
            )
        case .quiz:
            return quiz(
                action: action,
                history: history
            )
        }
    }

    /// publishes an updated history based on the action the user took, then returns that updated history
    private func publish(using action: AssistChatAction) -> AnyPublisher<[AssistChatMessage], Never> {
        var response: AssistChatResponse!
        switch action {
        case .chat(let prompt, let history):
            response = AssistChatResponse(
                AssistChatMessage(userResponse: prompt),
                chatHistory: history,
                isLoading: true
            )
        case .chip(let option, let history):
            response = AssistChatResponse(
                AssistChatMessage(
                    userResponse: option.chip,
                    prompt: option.prompt
                ),
                chatHistory: history,
                isLoading: true
            )
        }

        responsePublisher.send(response)

        return Just(response.chatHistory)
            .eraseToAnyPublisher()
    }

    /// Calls the cedar endpoint to generate a quiz
    private func quiz(
        action: AssistChatAction,
        history: [AssistChatMessage]
    ) -> AnyPublisher<AssistChatResponse, Error> {
        let pageContext = pageContextPublisher.value
        return cedarDomainService.api()
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
                                AssistChatMessage(
                                    botResponse: "Sorry, I'm unable to generate a quiz for you at this time."
                                ),
                                chatHistory: history
                            )
                        }
                        return AssistChatResponse(
                            AssistChatMessage(quizItem: quizItem),
                            chatHistory: history
                        )
                    }
                }
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Enum

    /// When requesting classification from basic chat, these are the options asked for
    private enum ClassifierOption: String, CaseIterable {
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
                return "flashcards (an assistant to help learner check their understanding with flashcards)"
            case .quiz:
                // swiftlint:disable line_length
                return
                    "quiz (an assistant that will prepare multiple choice quiz questions to help a user check their understanding); intended for terms/definitions or memorization). You should only respond with this if they are asking for a quiz."
                // swiftlint:enable line_length
            }
        }
    }
}

// MARK: - Extensions

private extension CedarGenerateQuizMutation.QuizOutput {
    var quizItems: [QuizItem] {
        data.generateQuiz.map {
            QuizItem(
                question: $0.question,
                answers: $0.options,
                correctAnswerIndex: $0.result
            )
        }
    }
}

private extension Array where Element == AssistChatMessage {
    var domainServiceConversationMessages: [DomainServiceConversationMessage] {
        prependUserMessage()
            .map {
                DomainServiceConversationMessage(
                    text: $0.prompt ?? $0.text ?? "",
                    role: $0.role == .Assistant ? .Assistant : .User
                )
            }
    }

    var json: String {
        guard let encoded = try? JSONEncoder().encode(self) else {
            return "[]"
        }
        return String(data: encoded, encoding: .utf8) ?? "[]"
    }

    private func prependUserMessage() -> [AssistChatMessage] {
        guard let first = first, first.role != .User else {
            return self
        }
        return [.init(userResponse: "Hello")] + self
    }
}

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
    let userShortNamePublisher: CurrentValueSubject<String, Never> = .init("")

    func publish(action: AssistChatAction) {}
    var listen: AnyPublisher<AssistChatResponse, Error> = Just(
        AssistChatResponse(
            AssistChatMessage(botResponse: "Welcome Back, Steve!")
        )
    )
    .setFailureType(to: Error.self)
    .eraseToAnyPublisher()
}

extension API {
    func makeRequest<Request: APIRequestable>(_ requestable: Request) -> AnyPublisher<Request.Response?, Error> {
        AnyPublisher<Request.Response?, Error> { [weak self] subscriber in
            self?.makeRequest(requestable) { response, _, error in
                if let error = error {
                    subscriber.send(completion: .failure(error))
                    return
                }
                subscriber.send(response)
            }
            return AnyCancellable { }
        }
    }
}
