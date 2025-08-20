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

    enum Failure: Swift.Error {
        case RequestFailed(String)
    }

    enum State {
        case success(AssistChatResponse)
        case failure(Failure)
    }

    enum AssetType: String, Codable {
        case File
        case Unknown
        case Page
    }

    enum CitationType: String, Codable {
        case wiki_page
        case attachment
        case unknown
    }
}

struct AssistRequest: APIRequestable {
    struct Body: Encodable {
        let prompt: String?
        let history: [AssistChatMessage]?
        let state: AssistState?
    }

    typealias Response = AssistResponse

    var body: Body? {
        Body(prompt: prompt, history: history, state: state)
    }
    var path: String {
        "assist"
    }
    var method: APIMethod = .post

    private let prompt: String?
    private let history: [AssistChatMessage]?
    private let state: AssistState?

    init(prompt: String?, history: [AssistChatMessage]?, state: AssistState?) {
        self.prompt = prompt
        self.history = history
        self.state = state
    }

    // TODO: Relocate Quiz Item, Flash Card, etc.
    struct AssistResponse: Codable {
        let state: AssistState?
        let statusCode: Int?
        let response: String?
        let chips: [AssistChipOption]?
        let flashCards: [AssistChatFlashCard]?
        let quizItems: [AssistChatMessage.QuizItem]?
        let citations: [AssistChatMessage.Citation]?
        let error: String?
    }
}

final class AssistChatInteractorLive: AssistChatInteractor {

    // MARK: - Private
    private var state: AssistState = .init()
    private var originalState: AssistState = .init()
    private var cancellable: AnyCancellable?
    private let responsePublisher = PassthroughSubject<AssistChatInteractorLive.State, Error>()
    private let journey: DomainService

    // MARK: - Init
    init(
        courseID: String? = nil,
        pageID: String? = nil,
        fileID: String? = nil,
        textSelection: String? = nil,
        journey: DomainService = .init(.journey)
    ) {
        self.state = .init(
            courseID: courseID,
            fileID: fileID,
            pageID: pageID,
            textSelection: textSelection
        )
        self.originalState = state.duplicate()
        self.journey = journey
    }

    // MARK: - Inputs
    /// Publishes a new user action to the interactor
    override
    func publish(prompt: String? = nil, history: [AssistChatMessage] = []) {
        weak var weakSelf = self
        cancellable?.cancel()
        cancellable = publishLearnersResponseAndAmmendHistory(prompt: prompt, history: history)
            .delay(for: .milliseconds(1), scheduler: DispatchQueue.main)
            .flatMap { ammendedHistory in
                guard let weakSelf = weakSelf else {
                    return Just<State?>(nil)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                return weakSelf.journey.api()
                    .flatMap { weakSelf.makeRequest(api: $0, prompt: prompt, history: ammendedHistory) }
                    .map { weakSelf.updateState(assistResponse: $0) }
                    .map { $0?.assistChatResponse(history: ammendedHistory) }
                    .eraseToAnyPublisher()
            }
            .compactMap { $0 }
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { assistChatResponse in
                    weakSelf?.responsePublisher.send(assistChatResponse)
                }
            )
    }

    private func makeRequest(api: API, prompt: String?, history: [AssistChatMessage]) -> AnyPublisher<AssistRequest.AssistResponse?, Error> {
        api.makeRequest(
            AssistRequest(
                prompt: prompt,
                history: history,
                state: state
            )
        )
        .map { assistResponse, _ in assistResponse }
        .eraseToAnyPublisher()
    }

    private func updateState(assistResponse: AssistRequest.AssistResponse?) -> AssistRequest.AssistResponse? {
        if assistResponse?.statusCode == 401 && assistResponse?.error == nil {
            return AssistRequest.AssistResponse(
                state: state,
                statusCode: assistResponse?.statusCode,
                response: assistResponse?.response,
                chips: assistResponse?.chips,
                flashCards: assistResponse?.flashCards,
                quizItems: assistResponse?.quizItems,
                citations: assistResponse?.citations,
                error: "Please log in to continue."
            )
        }
        state = assistResponse?.state ?? state
        return assistResponse
    }

    private func publishLearnersResponseAndAmmendHistory(prompt: String?, history: [AssistChatMessage]) -> Just<[AssistChatMessage]> {
        let isPromptEmpty = prompt?.isEmpty != false

        let response: AssistChatResponse = isPromptEmpty ?
            .init(history: history, isLoading: true) :
            .init(
                .init(userResponse: prompt ?? ""),
                history: history,
                isLoading: true
            )

        responsePublisher.send(.success(response))

        return Just(response.history)
    }

    /// Subscribe to the responses from the interactor
    override
    var listen: AnyPublisher<AssistChatInteractorLive.State, Error> {
        responsePublisher.eraseToAnyPublisher()
    }

    override
    func setInitialState() {
        cancellable?.cancel()
        self.state = self.originalState.duplicate()
        publish()
    }
}

extension AssistRequest.AssistResponse {
    func assistChatResponse(history: [AssistChatMessage]) -> AssistChatInteractor.State {
        if let error {
            return .failure(.RequestFailed(error))
        }
        return .success(
            AssistChatResponse(
                .init(
                    botResponse: response,
                    chipOptions: chips,
                    flashCards: flashCards,
                    quizItems: quizItems,
                    citations: citations
                ),
                history: history
            )
        )
    }
}

extension AssistState {
    func duplicate() -> AssistState {
        .init(
            courseID: courseID,
            fileID: fileID,
            pageID: pageID,
            textSelection: textSelection
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
                    history: []
                )
            )
        )
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    }

    override
    func setInitialState() {}
}
