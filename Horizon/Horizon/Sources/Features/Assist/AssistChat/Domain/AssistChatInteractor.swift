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
    func setInitialState()
    var listen: AnyPublisher<AssistChatInteractorLive.State, Never> { get }
}

final class AssistChatInteractorLive: AssistChatInteractor {
    enum State {
        case success(AssistChatResponse)
        case failure(Error)
    }
    // MARK: - Dependencies

    private let cedarDomainService: DomainService
    private let downloadFileInteractor: DownloadFileInteractor?
    private let pineDomainService: DomainService

    // MARK: - Private

    private let actionPublisher = CurrentValueRelay<AssistChatAction?>(nil)
    private let assistDataEnvironment: AssistDataEnvironment = AssistDataEnvironment()
    private var pageContextPublisher: AnyPublisher<AssistChatPageContext, Error>?
    private let initialStatePublisher = PassthroughSubject<Void, Never>()
    private var actionCancellable: AnyCancellable?
    private let responsePublisher = PassthroughSubject<AssistChatInteractorLive.State, Never>()
    private var subscriptions = Set<AnyCancellable>()
    private let userID: String
    private let goalChain: [any Goal]

    // MARK: - init

    /// Initializes the interactor when viewing a page for context
    convenience init(
        courseId: String,
        pageUrl: String,
        cedarDomainService: DomainService = DomainService(.cedar),
        pineDomainService: DomainService = DomainService(.pine)
    ) {
        self.init(
            pageContextPublisher: AssistChatInteractorLive.pageContextPublisher(
                courseId: courseId,
                pageUrl: pageUrl
            ),
            cedarDomainService: cedarDomainService,
            pineDomainService: pineDomainService
        )
    }

    /// Initializes the interactor when viewing a file for context
    convenience init(
        courseId: String,
        fileId: String,
        downloadFileInteractor: DownloadFileInteractor,
        cedarDomainService: DomainService = DomainService(.cedar),
        pineDomainService: DomainService = DomainService(.pine)
    ) {
        self.init(
            pageContextPublisher: AssistChatInteractorLive.pageContextPublisher(
                downloadFileInteractor: downloadFileInteractor,
                courseId: courseId,
                fileId: fileId
            ),
            cedarDomainService: cedarDomainService,
            pineDomainService: pineDomainService,
            downloadFileInteractor: downloadFileInteractor
        )
    }

    init(
        pageContextPublisher: AnyPublisher<AssistChatPageContext, Error>? = nil,
        cedarDomainService: DomainService = DomainService(.cedar),
        pineDomainService: DomainService = DomainService(.pine),
        downloadFileInteractor: DownloadFileInteractor? = nil,
        userID: String = AppEnvironment.shared.currentSession?.userID ?? ""
    ) {
        self.cedarDomainService = cedarDomainService
        self.pineDomainService = pineDomainService
        self.downloadFileInteractor = downloadFileInteractor
        self.pageContextPublisher = pageContextPublisher
        self.userID = userID
        self.goalChain = [
            SelectCourseGoal(environment: assistDataEnvironment),
            SelectCourseActionGoal(environment: assistDataEnvironment)
        ]

        initialStatePublisher
            .flatMap { [weak self] _ -> AnyPublisher<(AssistChatPageContext, String), Error> in
                guard let self = self else {
                    return Empty(completeImmediately: true).eraseToAnyPublisher()
                }
                return self.prepareCombinedPublisher()
            }
            .flatMap { [weak self] context, userShortName -> AnyPublisher<AssistChatResponse, Error> in
                guard let self = self else {
                    return Empty(completeImmediately: true).eraseToAnyPublisher()
                }
                return self.actionHandler(
                    action: .chat(prompt: "", history: []),
                    pageContext: context,
                    userShortName: userShortName
                )
            }
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] response in
                    self?.responsePublisher.send(.success(response))
                }
            )
            .store(in: &subscriptions)
    }

    // MARK: - Inputs

    /// Publishes a new user action to the interactor
    func publish(action: AssistChatAction) {
        actionPublisher.accept(action)
        actionCancellable = actionPublisher
            .compactMap { $0 }
            .flatMap { [weak self] action -> AnyPublisher<(AssistChatAction, AssistChatPageContext, String), Error> in
                guard let self = self else {
                    return Just((action, AssistChatPageContext(), ""))
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                return self.prepareCombinedPublisher()
                    .map { (pageContext, userShortName) in
                        (action, pageContext, userShortName)
                    }
                    .eraseToAnyPublisher()
            }
            .flatMap { [weak self] action, pageContext, userShortName in
                guard let self = self else {
                    return Empty<AssistChatResponse, Error>(completeImmediately: true).eraseToAnyPublisher()
                }
                return self.actionHandler(
                    action: action,
                    pageContext: pageContext,
                    userShortName: userShortName
                )
            }
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.responsePublisher.send(.failure(error))
                    }
                },
                receiveValue: { [weak self] response in
                    self?.responsePublisher.send(.success(response))
                }
            )
    }

    func setInitialState() {
        // Cancel any previously triggered API calls.
        actionCancellable?.cancel()
        actionCancellable = nil
        initialStatePublisher.send(())
    }

    /// Subscribe to the responses from the interactor
    var listen: AnyPublisher<AssistChatInteractorLive.State, Never> {
        responsePublisher
            .eraseToAnyPublisher()
    }

    // MARK: - Private

    private func prepareCombinedPublisher() -> AnyPublisher<(AssistChatPageContext, String), Error> {
        let contextPublisher = pageContextPublisher ?? Just(AssistChatPageContext())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()

        return Publishers.CombineLatest(contextPublisher, userShortNamePublisher)
            .eraseToAnyPublisher()
    }

    /// When a new action comes in from the user, this function starts processing it
    private func actionHandler(
        action: AssistChatAction,
        pageContext: AssistChatPageContext,
        userShortName: String
    ) -> AnyPublisher<AssistChatResponse, any Error> {
        var prompt: String!
        var history: [AssistChatMessage]!
        var useAdvancedChat = false

        switch action {
        case .chat(let message, let chatHistory):
            prompt = message
            history = chatHistory
            // only use the advanced chat if we don't have a document context
            useAdvancedChat = pageContext.prompt == nil
        case .chip(let option, let chatHistory):
            prompt = option.prompt
            history = chatHistory
            useAdvancedChat = false
        }

        if let publisher = executeGoalChain(prompt: prompt, history: history) {
            return publisher
        }

        return publish(using: action, with: userShortName)
            .flatMap { [weak self] newHistory -> AnyPublisher<AssistChatResponse, Error> in
                guard let self = self else {
                    return Empty(completeImmediately: true).eraseToAnyPublisher()
                }

                return self.classifier(
                    prompt: prompt,
                    pageContext: pageContext,
                    userShortName: userShortName,
                    action: action,
                    history: newHistory
                )
                .flatMap { classification -> AnyPublisher<AssistChatResponse, Error> in
                    return self.handleClassifierPromptResponse(
                        classification: classification,
                        action: action,
                        pageContext: pageContext,
                        history: newHistory,
                        userShortName: userShortName,
                        useAdvancedChat: useAdvancedChat
                    )
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func executeGoalChain(
        prompt: String = "",
        history: [AssistChatMessage] = []
    ) -> AnyPublisher<AssistChatResponse, any Error>? {
        guard let goal = goalChain.first(where: { $0.isRequested() }) else {
            return nil
        }
        if prompt.isEmpty {
            return goal.options.flatMap { goalOptions in
                Just(
                    .init(
                        .init(
                            botResponse: goal.userPrompt,
                            chipOptions: goalOptions.map {
                                .init(chip: $0.text, prompt: $0.text)
                            }
                        ),
                        chatHistory: history
                    )
                )
                .setFailureType(to: Error.self)
            }
            .eraseToAnyPublisher()
        }

        let response = AssistChatResponse(
            .init(userResponse: prompt),
            chatHistory: history,
            isLoading: true
        )
        let revisedHistory = response.chatHistory
        responsePublisher.send(.success(response))

        return goal.execute(response: prompt, history: revisedHistory)
            .flatMap { [weak self] assistChatMessage in
                guard let self = self else {
                    return Empty<AssistChatResponse, any Error>(completeImmediately: true).eraseToAnyPublisher()
                }
                if let assistChatMessage = assistChatMessage {
                    let response = AssistChatResponse(
                        assistChatMessage,
                        chatHistory: revisedHistory
                    )
                    return Just(.init(assistChatMessage, chatHistory: response.chatHistory))
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                return self.executeGoalChain(history: revisedHistory)!
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    /// Returns any configured chips to show based on the context. If there are none, we return a default message
    private func buildInitialResponse(for pageContext: AssistChatPageContext, with userShortName: String) -> AnyPublisher<AssistChatResponse, Error> {
        let options = pageContext.chips.map { option in
            AssistChipOption(
                option,
                userShortName: userShortName
            )
        }
        let message = String(localized: "How can I help today?", bundle: .horizon)
        let chatBotResponse =
            options.isEmpty
        ? AssistChatResponse(.init(botResponse: message))
        : AssistChatResponse(.init(botResponse: message, chipOptions: options))

        return Just(chatBotResponse)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    /// If necessary, downloads the file and returns the page context.
    /// If we can't determine the format, we return an empty page context
    private static func pageContextPublisher(
        downloadFileInteractor: DownloadFileInteractor,
        courseId: String,
        fileId: String
    ) -> AnyPublisher<AssistChatPageContext, Error> {
        ReactiveStore(useCase: GetFile(context: .course(courseId), fileID: fileId))
            .getEntities()
            .map { files in files.first }
            .flatMap { (file: File?) in
                guard let file = file,
                      let format = AssistChatDocumentType.from(mimeType: file.contentType) else {
                    return Just(AssistChatPageContext()).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
                return downloadFileInteractor
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
    }

    /// Fetches a page to use for AI context
    private static func pageContextPublisher(courseId: String, pageUrl: String) -> AnyPublisher<AssistChatPageContext, Error> {
        ReactiveStore(useCase: GetPage(context: .course(courseId), url: pageUrl))
            .getEntities()
            .map { AssistChatPageContext(title: $0.first?.title ?? "", body: $0.first?.body ?? "") }
            .eraseToAnyPublisher()
    }

    /// Makes a request to the cedar endpoint using the given prompt and returns an answer
    private func basicChat(
        prompt: String,
        pageContext: AssistChatPageContext? = nil
    ) -> AnyPublisher<String, Error> {
        cedarDomainService.api()
            .flatMap { cedarApi in
                cedarApi.makeRequest(
                    CedarAnswerPromptMutation(
                        prompt: prompt,
                        document: CedarAnswerPromptMutation.DocumentInput.build(from: pageContext)
                    )
                )
            }
            .map { graphQlResponse, _ in graphQlResponse.data.answerPrompt }
            .eraseToAnyPublisher()
    }

    /// Given the prompt, ask the AI to classify it to one of our ClassifierOptions (e.g., chat, flashcards, quiz)
    private func classifier(
        prompt: String,
        pageContext: AssistChatPageContext,
        userShortName: String,
        action: AssistChatAction,
        history: [AssistChatMessage]
    ) -> AnyPublisher<String, Error> {
        let longExplanations = ClassifierOption.allCases.map { $0.longExplanation }.joined(separator: ", ")
        let defaultOption = ClassifierOption.defaultOption.rawValue
        let shortOptions = ClassifierOption.allCases.map { $0.rawValue }.joined(separator: ", ")

        // swiftlint:disable line_length
        let classifierPrompt =
            "You are an agent designed to route a learner's question to the appropriate assistant. The possible assistants are \(longExplanations). If you're not sure, choose \(defaultOption). ALWAYS answer with a single word - either \(shortOptions). Here's the learner's question: \(prompt). Here is our chat history in JSON: \(history.json)"
        // swiftlint:enable line_length

        return basicChat(prompt: classifierPrompt, pageContext: pageContext)
    }

    private func courseSelectionResponse(chatHistory: [AssistChatMessage]) -> AnyPublisher<AssistChatResponse, any Error> {
            ReactiveStore(
                useCase: GetHCoursesProgressionUseCase(userId: userID)
            )
            .getEntities()
            .map { [weak self] courses in
                if courses.count > 1 {
                    return .courseSelection(
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

    /// Calls the basic chat endpoint to generate flashcards
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
                AssistChatMessage(
                    flashCards: AssistChatFlashCard.build(from: response) ?? []
                ),
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
        pageContext: AssistChatPageContext,
        history: [AssistChatMessage],
        userShortName: String,
        useAdvancedChat: Bool = true
    ) -> AnyPublisher<AssistChatResponse, Error> {
        let defaultOption = ClassifierOption.defaultOption
        let classifierOption = ClassifierOption(rawValue: classification) ?? defaultOption
        switch classifierOption {
        case .chat:
            let chatMethod = basicChat(prompt: "\(history.json) \(pageContext.prompt ?? "")", pageContext: pageContext)
            return
                chatMethod
                .map { AssistChatResponse(AssistChatMessage(botResponse: $0), chatHistory: history) }
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

    /// publishes an updated history based on the action the user took, then returns that updated history
    private func publish(using action: AssistChatAction, with userShortName: String) -> AnyPublisher<[AssistChatMessage], any Error> {
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
                .init(
                    userResponse: option.chip,
                    prompt: option.prompt
                ),
                chatHistory: history,
                isLoading: true
            )
        }

        responsePublisher.send(.success(response))

        return Just(response.chatHistory)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    /// Calls the cedar endpoint to generate a quiz
    private func quiz(
        action: AssistChatAction,
        pageContext: AssistChatPageContext,
        history: [AssistChatMessage],
        userShortName: String
    ) -> AnyPublisher<AssistChatResponse, Error> {
        cedarDomainService.api()
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
                        return AssistChatResponse(
                            AssistChatMessage(
                                quizItems: quizOutput.quizItems
                            ),
                            chatHistory: history
                        )
                    }
                }
            }
            .eraseToAnyPublisher()
    }

    /// Fetches the user's short name
    private var userShortNamePublisher: AnyPublisher<String, Error> {
        ReactiveStore(useCase: GetUserProfile())
            .getEntities()
            .map { $0.first?.shortName ?? String(localized: "Learner", bundle: .horizon) }
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
            .init(
                question: $0.question,
                answers: $0.options,
                correctAnswerIndex: $0.result
            )
        }
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
