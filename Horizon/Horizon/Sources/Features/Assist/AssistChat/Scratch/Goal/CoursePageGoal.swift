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
import Foundation

class CoursePageGoal: Goal {

    private enum Option: String, CaseIterable {
        case Summarize = "Summarize"
        case KeyTakeaways = "Key Takeaways"
        case TellMeMore = "Tell me more"
        case FlashCards = "Flash Cards"
        case Quiz = "Quiz Questions"
        case Translate = "Translate to Spanish"
    }

    private let cedar: DomainService
    private var courseID: String? {
        environment.courseID.value
    }
    private var pageURL: String? {
        environment.pageURL.value
    }
    private var options: [Option] {
        Option.allCases
    }
    private var chipOptions: [String] {
        options.map(\.rawValue)
    }

    private let environment: AssistDataEnvironment

    init(environment: AssistDataEnvironment, cedar: DomainService = DomainService(.cedar)) {
        self.environment = environment
        self.cedar = cedar
    }

    override
    func execute(response: String?, history: [AssistChatMessage]) -> AnyPublisher<AssistChatMessage?, any Error> {
        guard let response = response, response.isNotEmpty else {
            return initialPrompt()
        }
        return choose(from: chipOptions, with: response, using: cedar)
            .flatMap { [weak self] chip in
                let nilResponse = Just<AssistChatMessage?>(nil).setFailureType(to: Error.self).eraseToAnyPublisher()
                guard let self = self,
                      let chip = chip,
                      let option = self.options.first(where: { chip.contains($0.rawValue) }) else {
                        return nilResponse
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
                default:
                    return Just(nil)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    override
    func isRequested() -> Bool { courseID != nil && pageURL != nil }

    // MARK: - Private Methods

    /// https://github.com/instructure-internal/cedar/blob/main/docs/index.md#answer-prompt
    private func cedarAnswerPrompt(
        prompt: String,
        document: CedarAnswerPromptMutation.DocumentInput? = nil
    ) -> AnyPublisher<String?, Error> {
        cedar.api()
            .flatMap { cedarApi in
                cedarApi.makeRequest(
                    CedarAnswerPromptMutation(
                        prompt: prompt,
                        document: document
                    )
                )
                .map { (response: CedarAnswerPromptMutationResponse?) in
                    response?.data.answerPrompt
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
                .map { (response: CedarConversationMutationResponse?) in
                    response?.data.conversation.response
                }
            }
            .eraseToAnyPublisher()
    }

    /// https://github.com/instructure-internal/cedar/blob/main/docs/index.md#summarize-content
    private func cedarSummarizeContent(content: String) -> AnyPublisher<[String]?, Error> {
        cedar.api()
            .flatMap { cedarApi in
                cedarApi.makeRequest(
                    CedarSummarizeContentMutation(content: content)
                )
                .map { (response: CedarSummarizeContentMutationResponse?) in
                    response?.data.summarizeContent.summarization
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func cedarTranslate(html: String, language: String = "es") -> AnyPublisher<String?, Error> {
        cedar.api()
            .flatMap { cedarApi in
                cedarApi.makeRequest(
                    CedarTranslateHTMLMutation(content: html, targetLanguage: language)
                )
                .map { (response: CedarTranslatHTMLMutationResponse?) in
                    response?.data.translateHTML.translation
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    /// Calls the basic chat endpoint to generate flashcards
    private func flashcards() -> AnyPublisher<AssistChatMessage?, Error> {
        page.flatMap { [weak self] page in
            guard let self = self else {
                return Just<AssistChatMessage?>(nil)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            let body = page?.body ?? ""
            // swiftlint:disable line_length
            let prompt = "You are a teaching assistant creating flash cards to test a student. Give me 7 questions with answers based on the included document contents. Ignore any HTML. Return the result in JSON format like: [{question: '', answer: ''}, {question: '', answer: ''}] without any further description or text. Your flash cards should not refer to the format of the content, but rather the content itself. Here is the content: \(body)"
            // swiftlint:enable line_length
            return self.cedarAnswerPrompt(prompt: prompt)
                .map { (response: String?) in
                    AssistChatMessage(
                        flashCards: AssistChatFlashCard.build(from: response ?? "") ?? []
                    )
                }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    private func initialPrompt() -> AnyPublisher<AssistChatMessage?, Error> {
        Just(
            .init(
                botResponse: "How can I help you with this page?",
                chipOptions: chipOptions.map { .init(chip: $0) }
            )
        )
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    }

    private func keyTakeaways() -> AnyPublisher<AssistChatMessage?, Error> {
        page.flatMap { [weak self] page in
            guard let self = self else {
                return Just<AssistChatMessage?>(nil)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            let body = page?.body ?? ""
            // swiftlint:disable line_length
            let prompt = "You are a teaching assistant creating key takeaways for a student. Give me 3 key takeaways based on the included document contents. Ignore any HTML. Return the result in paragraph form. Each key takeaway is a single sentence bulletpoint. You should not refer to the format of the content, but rather the content itself. Here is the content: \(body)"
            // swiftlint:enable line_length
            return self.cedarAnswerPrompt(prompt: prompt)
                .map { (response: String?) in
                    .init(botResponse: response ?? "No key takeaways found.")
                }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    /// Fetches a page to use for AI context
    private var page: AnyPublisher<Page?, Error> {
        guard let courseID = courseID, let pageURL = pageURL else {
            return Just<Page?>(nil).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        return ReactiveStore(useCase: GetPage(context: .course(courseID), url: pageURL))
            .getEntities()
            .map { $0.first }
            .eraseToAnyPublisher()
    }

    /// Calls the cedar endpoint to generate a quiz
    private func quiz() -> AnyPublisher<AssistChatMessage?, Error> {
        page.flatMap { [weak self] (page: Page?) in
            guard let prompt = page?.body,
                let self = self else {
                return Just<AssistChatMessage?>(nil).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            return cedar.api()
                .flatMap { cedarApi in
                    cedarApi.makeRequest(
                        CedarGenerateQuizMutation(context: prompt)
                    )
                    .compactMap { (quizOutput: CedarGenerateQuizMutation.QuizOutput?) in
                        quizOutput.map { quizOutput in
                            AssistChatMessage(
                                quizItems: quizOutput.quizItems
                            )
                        }
                    }
                }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    private func summarizeContent() -> AnyPublisher<AssistChatMessage?, Error> {
        page.flatMap { [weak self] page in
            guard let self = self else {
                return Just<AssistChatMessage?>(nil)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            let body = page?.body ?? ""
            return self.cedarSummarizeContent(content: body)
                .map { (summaries: [String]?) in
                    AssistChatMessage(
                        botResponse: (summaries ?? []).joined(separator: "\n\n")
                    )
                }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    private func tellMeMore() -> AnyPublisher<AssistChatMessage?, Error> {
        page.flatMap { [weak self] page in
            guard let self = self else {
                return Just<AssistChatMessage?>(nil)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            let body = page?.body ?? ""
            // swiftlint:disable line_length
            let prompt = "You are a teaching assistant providing more information about the content. Give me more details based on the included document contents. Ignore any HTML. Return the result in paragraph form. Here is the content: \(body)"
            // swiftlint:enable line_length
            return self.cedarAnswerPrompt(prompt: prompt)
                .map { (response: String?) in
                    AssistChatMessage(
                        botResponse: response ?? "No additional information found."
                    )
                }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    private func translate(response: String) -> AnyPublisher<AssistChatMessage?, Error> {
        translateDetermineLanguage(response: response)
        .flatMap { [weak self] (language: String?) in
            guard let language = language,
                  let self = self else {
                return Just<(Page?, String?)>((nil, nil)).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            return self.page.map { page in
                (page, language)
            }
            .eraseToAnyPublisher()
        }
        .flatMap { [weak self] (tuple: (Page?, String?)) in
            guard let body = tuple.0?.body,
                  let language = tuple.1,
                  let self = self else {
                return Just<String?>(nil).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            return self.cedarTranslate(
                html: body.prefix(5000).description,
                language: language
            )
        }
        .flatMap { [weak self] (translation: String?) in
            guard let translation = translation,
                  let translationUtf8 = translation.data(using: .utf8)?.base64EncodedString(),
                  let self = self else {
                return Just<String?>(nil)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            return self.cedarAnswerPrompt(
                // swiftlint:disable line_length
                prompt: "Convert this HTML document to a text document. Strip out all HTML tags and return the text content only. You may try to use ASCII to represent the HTML tags. For instance, * may be used for bullet points.",
                // swiftlint:enable line_length
                document: CedarAnswerPromptMutation.DocumentInput(
                    format: .txt,
                    base64Source: translationUtf8
                )
            )
        }
        .map { (result: String?) in
            AssistChatMessage(
                botResponse: result ?? "Sorry, I couldn't translate that page."
            )
        }
        .eraseToAnyPublisher()
    }

    private func translateDetermineLanguage(response: String) -> AnyPublisher<String?, Error> {
        cedarAnswerPrompt(
            // swiftlint:disable line_length
            prompt: "The user has asked to have a document translated. From their response, determine what language they would like the language translated to. Return the language as a two letter ISO 639-1 code. Only include the two letter code your response, nothing else"
            // swiftlint:enable line_length
        )
    }
}

extension CedarGenerateQuizMutation.QuizOutput {
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
