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
import Core

/// This is a base class for the course page and course document goals
/// It's not meant to be instantiated directly, but rather to be subclassed
class AssistCourseItemGoal: AssistGoal {

    enum Option: String, CaseIterable {
        case Summarize = "Summarize"
        case KeyTakeaways = "Key Takeaways"
        case TellMeMore = "Tell me more"
        case FlashCards = "Flash Cards"
        case Quiz = "Quiz Questions"
        case Rephrase = "Rephrase Content"
    }

    // MARK: - Properties
    var courseID: String? {
        environment.courseID.value
    }

    var options: [Option] {
        Option.allCases
    }

    // MARK: - Dependencies
    let environment: AssistDataEnvironment
    let cedar: DomainService
    private let initialPrompt: String
    private let pine: DomainService
    var sourceType: AssistChatInteractor.AssetType = .unknown

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
        cedar: DomainService = DomainService(.cedar),
        pine: DomainService = DomainService(.pine)
    ) {
        self.initialPrompt = initialPrompt
        self.environment = environment
        self.cedar = cedar
        self.pine = pine
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
                    return self.pineAnswerPrompt(prompt: response)
                        .map { response in
                            AssistChatMessage(
                                botResponse: response ??
                                    String(localized: "Sorry, I don't have an answer for this.", bundle: .horizon)
                            )
                        }
                        .eraseToAnyPublisher()
                }

                switch option {
                case .FlashCards:
                    return self.flashcards()
                case .KeyTakeaways:
                    return self.keyTakeaways()
                case .Quiz:
                    return self.quiz()
                case .Rephrase:
                    return self.rephrase()
                case .Summarize:
                    return self.summarizeContent()
                case .TellMeMore:
                    return self.tellMeMore()
                }
            }
            .eraseToAnyPublisher()
    }

    func isRequested() -> Bool { false }

    // Quiz is not available for a document at the moment
    // And for a page, there's a separate cedar endpoint for generating the quiz
    // This method is overridden in the course page goal
    func quiz() -> AnyPublisher<AssistChatMessage?, Error> {
        Just(nil)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    /// Summarizes the content of the document
    func summarizeContent() -> AnyPublisher<AssistChatMessage?, Error> {
        cedarAnswerPrompt(
            forOption: .Summarize,
            errorResponse: String(localized: "I don't have a summary for this content.", bundle: .horizon)
        )
    }

    var sourceID: AnyPublisher<String?, Error> {
        guard let courseID = environment.courseID.value,
            let pageURL = environment.pageURL.value else {
            return Just(nil)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return ReactiveStore(useCase: GetPages(context: .course(courseID)))
            .getEntities()
            .map { pages in
                pages.first { $0.url == pageURL }?.id
            }
            .eraseToAnyPublisher()
    }

    private func pineAnswerPrompt(prompt: String) -> AnyPublisher<String?, Error> {
        sourceID.flatMap { [weak self] sourceID in
            guard let self = self,
                  let sourceID = sourceID else {
                return Just<String?>(nil)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            return self.pine.askARAGQuestion(
                question: prompt,
                courseID: courseID,
                sourceID: sourceID,
                sourceType: sourceType.rawValue
            )
        }
        .eraseToAnyPublisher()
    }

    private func cedarAnswerPrompt(
        forOption option: Option,
        errorResponse: String? = nil
    ) -> AnyPublisher<AssistChatMessage?, Error> {
        pineAnswerPrompt(prompt: option.prompt)
            .map { response in
                if let response = response, !response.isEmpty {
                    return AssistChatMessage(botResponse: response)
                } else {
                    return AssistChatMessage(
                        botResponse: errorResponse ?? String(localized: "I don't have an answer for this.", bundle: .horizon)
                    )
                }
            }
            .eraseToAnyPublisher()
    }

    /// Calls the Cedar endpoint for generating flashcards based on the document content
    private func flashcards() -> AnyPublisher<AssistChatMessage?, Error> {
        self.pineAnswerPrompt(prompt: Option.FlashCards.prompt)
        .map { (response: String?) in
            AssistChatMessage(
                flashCards: AssistChatFlashCard.build(from: response ?? "") ?? []
            )
        }
        .eraseToAnyPublisher()
    }

    /// Returns the key takeaways of the document
    private func keyTakeaways() -> AnyPublisher<AssistChatMessage?, Error> {
        cedarAnswerPrompt(
            forOption: .KeyTakeaways,
            errorResponse: String(localized: "No key takeaways found.", bundle: .horizon)
        )
    }

    /// Rephrases the content of the document
    private func rephrase() -> AnyPublisher<AssistChatMessage?, Error> {
        cedarAnswerPrompt(
            forOption: .Rephrase,
            errorResponse: String(localized: "I'm not able to rephrase this content", bundle: .horizon)
        )
    }

    /// Returns more information about the document
    private func tellMeMore() -> AnyPublisher<AssistChatMessage?, Error> {
        cedarAnswerPrompt(
            forOption: .TellMeMore,
            errorResponse: String(localized: "I don't have any additional information for you.", bundle: .horizon)
        )
    }
}

// swiftlint:disable line_length
extension AssistCourseItemGoal.Option {
    var prompt: String {
        let prompts: [AssistCourseItemGoal.Option: String] = [
            .Summarize: summarizeContent,
            .KeyTakeaways: keyTakeaways,
            .TellMeMore: tellMeMore,
            .FlashCards: flashCards,
            .Quiz: quiz,
            .Rephrase: rephraseContent
        ]
        return prompts[self] ?? ""
    }
    private var flashCards: String {
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
    private var keyTakeaways: String {
        "You are a teaching assistant creating key takeaways for a student. Give me 3 key takeaways based on the included document contents. Ignore any HTML. Return the result in paragraph form. Each key takeaway is a single sentence bulletpoint. You should not refer to the format of the content, but rather the content itself."
    }
    private var quiz: String {
        """
            You are a teaching assistant creating quiz questions based on the provided content. Generate 15 multiple-choice questions with 4 options each, where one option is correct. Each question should be concise and clear, and the correct answer index is zero based. Ignore any HTML. Return the result in JSON format with no additional information. Here is the JSON format to use: [{question: String, options: [String], result: Int}]}]. For instance, if the question is, "What is the capital of France?", the JSON would look like this: [{question: "What is the capital of France?", options: ["Paris", "London", "Berlin", "Madrid"], result: 0}]. Make sure the JSON is valid.
        """
    }
    private var rephraseContent: String {
        """
            You are a teaching assistant rephrasing content. Rephrase the provided content in a more concise and clear manner. Ignore any HTML. Return the result in paragraph form.
        """
    }
    private var summarizeContent: String {
        """
            You are a teaching assistant summarizing content. Give me a summary based on the included document contents. Ignore any HTML. Return the result in paragraph form.
        """
    }
    private var tellMeMore: String {
        """
            You are a teaching assistant providing more information about the content. Give me more details based on the included document contents. Ignore any HTML. Return the result in paragraph form.
        """
    }
}
// swiftlint:enable line_length
