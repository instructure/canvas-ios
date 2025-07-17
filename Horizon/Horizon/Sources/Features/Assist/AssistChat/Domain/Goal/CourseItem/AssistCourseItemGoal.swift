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

/// This is a base class for the course page and course document goals
/// It's not meant to be instantiated directly, but rather to be subclassed
class AssistCourseItemGoal: AssistGoal {

    enum Option: String, CaseIterable {
        case Summarize = "Summarize"
        case KeyTakeaways = "Key Takeaways"
        case TellMeMore = "Tell me more"
        case FlashCards = "Flash Cards"
        case Quiz = "Quiz Questions"
    }

    // MARK: - Properties
    var courseID: String? {
        environment.courseID.value
    }

    var document: AnyPublisher<CedarAnswerPromptMutation.DocumentInput?, Error> {
        return Just(nil)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    var options: [Option] {
        Option.allCases
    }

    // MARK: - Dependencies
    let environment: AssistDataEnvironment
    let cedar: DomainService
    private let initialPrompt: String

    // MARK: - Private
    private var chipOptions: [String] {
        options.map(\.rawValue)
    }

    private var goalOptions: [AssistGoalOption] {
        options.map { AssistGoalOption(name: $0.rawValue) }
    }

    // MARK: - Initializers
    init(
        initialPrompt: String,
        environment: AssistDataEnvironment,
        cedar: DomainService = DomainService(.cedar)
    ) {
        self.initialPrompt = initialPrompt
        self.environment = environment
        self.cedar = cedar
    }

    /// Executes the goal based on the response from the user.
    /// Chooses from one of the options or answers the user's question if no option is selected.
    func execute(response: String?, history: [AssistChatMessage]) -> AnyPublisher<AssistChatMessage?, any Error> {
        guard let response = response, response.isNotEmpty else {
            return Just(
                .init(
                    botResponse: initialPrompt,
                    chipOptions: chipOptions.map { .init(chip: $0) }
                )
            )
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        }
        return choose(from: goalOptions, with: response, using: cedar)
            .flatMap { [weak self] chip in
                let nilResponse = Just<AssistChatMessage?>(nil).setFailureType(to: Error.self).eraseToAnyPublisher()

                guard let self = self else {
                    return nilResponse
                }

                // If a chip wasn't chosen, just try to answer what they said
                guard let chip = chip,
                      let option = self.options.first(where: { chip.contains($0.rawValue) }) else {
                    return self.cedarAnswerPrompt(prompt: response)
                }

                switch option {
                case .KeyTakeaways:
                    return self.keyTakeaways()
                case .Summarize:
                    return self.summarizeContent()
                case .TellMeMore:
                    return self.tellMeMore()
                case .Quiz:
                    return self.quiz()
                case .FlashCards:
                    return self.flashcards()
                }
            }
            .eraseToAnyPublisher()
    }

    func isRequested() -> Bool {
        false
    }

    /// Summarizes the content of the document
    func summarizeContent() -> AnyPublisher<AssistChatMessage?, Error> {
        document.flatMap { [weak self] document in
            guard let self = self,
                  let document = document else {
                return Just<AssistChatMessage?>(nil)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            return self.cedarAnswerPrompt(
                prompt: .summarizeContent,
                document: document
            )
            .map { response in
                AssistChatMessage(
                    botResponse: response ?? String(localized: "No summary found.", bundle: .horizon)
                )
            }
            .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    func quiz() -> AnyPublisher<AssistChatMessage?, Error> {
        Just(nil)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    // MARK: - Private Functions
    /// Given a prompt, fetches the page document and makes a request to the cedar endpoint for answering a question
    private func cedarAnswerPrompt(prompt: String) -> AnyPublisher<AssistChatMessage?, Error> {
        document
            .flatMap { [weak self] document in
                guard let self = self, let document = document else {
                    return Just<AssistChatMessage?>(nil)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                return self.cedarAnswerPrompt(prompt: prompt, document: document)
                    .map { response in
                        AssistChatMessage(
                            botResponse: response ?? String(localized: "Sorry, I don't have an answer for that right now.", bundle: .horizon)
                        )
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    /// Given a prompt and a document, makes a request to the cedar endpoint for answering a question
    /// https://github.com/instructure-internal/cedar/blob/main/docs/index.md#answer-prompt
    private func cedarAnswerPrompt(
        prompt: String,
        document: CedarAnswerPromptMutation.DocumentInput
    ) -> AnyPublisher<String?, Error> {
        cedar.api()
            .flatMap { cedarApi in
                cedarApi.makeRequest(
                    CedarAnswerPromptMutation(
                        prompt: prompt,
                        document: document
                    )
                )
                .map { (response, _) in
                    response.data.answerPrompt
                }
            }
            .eraseToAnyPublisher()
    }

    /// Makes a request to the cedar endpoint using the given prompt and returns an answer
    /// https://github.com/instructure-internal/cedar/blob/main/docs/index.md#conversation
    private func cedarConversation(
        prompt: String,
        history: [AssistChatMessage] = []
    ) -> AnyPublisher<String?, Error> {
        cedar.api()
            .flatMap { cedarApi in
                cedarApi.makeRequest(
                    CedarConversationMutation(
                        systemPrompt: prompt,
                        messages: history.domainServiceConversationMessages
                    )
                )
                .map { (response, _) in
                    response.data.conversation.response
                }
            }
            .eraseToAnyPublisher()
    }

    /// Calls the Cedar endpoint for generating flashcards based on the document content
    private func flashcards() -> AnyPublisher<AssistChatMessage?, Error> {
        document.flatMap { [weak self] document in
            guard
                let self = self,
                let document = document else {
                return Just<AssistChatMessage?>(nil)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            return self.cedarAnswerPrompt(
                prompt: .flashCards,
                document: document
            )
                .map { (response: String?) in
                    AssistChatMessage(
                        flashCards: AssistChatFlashCard.build(from: response ?? "") ?? []
                    )
                }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    /// Returns the key takeaways of the document
    private func keyTakeaways() -> AnyPublisher<AssistChatMessage?, Error> {
        document.flatMap { [weak self] document in
            guard let self = self,
                  let document = document else {
                return Just<AssistChatMessage?>(nil)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            return self.cedarAnswerPrompt(
                prompt: .keyTakeaways,
                document: document
            )
            .map { (response: String?) in
                .init(botResponse: response ?? String(localized: "No key takeaways found.", bundle: .horizon))
            }
            .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    /// Returns more information about the document
    private func tellMeMore() -> AnyPublisher<AssistChatMessage?, Error> {
        document.flatMap { [weak self] document in
            guard let self = self,
                  let document = document else {
                return Just<AssistChatMessage?>(nil)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            return self.cedarAnswerPrompt(
                prompt: .tellMeMore,
                document: document
            )
                .map { (response: String?) in
                    AssistChatMessage(
                        botResponse: response ?? String(localized: "No additional information found.", bundle: .horizon)
                    )
                }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}

extension String {
    var base64EncodedString: String? {
        guard let data = data(using: .utf8) else { return nil }
        return data.base64EncodedString()
    }
}

// swiftlint:disable line_length
extension String {
    static var flashCards: String {
        """
            generate exactly 20 questions and answers based on the provided content for the front and back of flashcards, respectively. If the content contains only an iframe dont try to generate an answer. Flashcards are best suited for definitions and terminology, key concepts and theories, language learning, historical events and dates, and other content that might benefit from active recall and repetition. Prioritize this type of content within the flashcards.
                        Return the flashcards as a valid JSON array in the following format:
                        [
                          {
                            "question": "What is the title of the video?",
                            "answer": "What Is Accountability?"
                          }
                        ]
            without any further description or text. Please keep the questions and answers concise (under 35 words). Each question and answer will be shown on a flashcard, so no need to repeat the question in the answer. Make sure the JSON is valid.
        """
    }
    static var keyTakeaways: String {
        "You are a teaching assistant creating key takeaways for a student. Give me 3 key takeaways based on the included document contents. Ignore any HTML. Return the result in paragraph form. Each key takeaway is a single sentence bulletpoint. You should not refer to the format of the content, but rather the content itself."
    }
    static var summarizeContent: String {
        """
            You are a teaching assistant summarizing content. Give me a summary based on the included document contents. Ignore any HTML. Return the result in paragraph form.
        """
    }
    static var tellMeMore: String {
        """
            You are a teaching assistant providing more information about the content. Give me more details based on the included document contents. Ignore any HTML. Return the result in paragraph form.
        """
    }
}
// swiftlint:enable line_length
