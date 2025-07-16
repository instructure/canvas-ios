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

/// Interacting with a course page in the context of the Assist feature.
class HCoursePageGoal: HCourseItemGoal {
    // MARK: - Private
    private var pageURL: String? {
        environment.pageURL.value
    }

    private let initialPrompt = String(localized: "How can I help you with this page?", bundle: .horizon)

    // MARK: - Initializers
    init(environment: AssistDataEnvironment, cedar: DomainService = DomainService(.cedar)) {
        super.init(
            initialPrompt: initialPrompt,
            environment: environment,
            cedar: cedar
        )
    }

    // MARK: - Overrides
    /// Converts the course page content into a document format suitable for Cedar API requests.
    override
    var document: AnyPublisher<CedarAnswerPromptMutation.DocumentInput?, Error> {
        body.map { body in
            guard let base64Source = body?.base64EncodedString else {
                return nil
            }
            return CedarAnswerPromptMutation.DocumentInput(
                format: .txt,
                base64Source: base64Source
            )
        }
        .eraseToAnyPublisher()
    }

    override
    func isRequested() -> Bool { courseID != nil && pageURL != nil }

    /// Generates a quiz from the page contents using the Cedar API.
    override
    func quiz() -> AnyPublisher<AssistChatMessage?, Error> {
        body.flatMap { [weak self] body in
            guard let self = self,
                  let body = body else {
                return Just<AssistChatMessage?>(nil)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            return cedar.api()
                .flatMap { cedarApi in
                    cedarApi.makeRequest(
                        CedarGenerateQuizMutation(context: body)
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

    /// Summarizes the page contents using the Cedar endpoint for content summarization.
    override
    func summarizeContent() -> AnyPublisher<AssistChatMessage?, Error> {
        body.flatMap { [weak self] body in
            guard let self = self,
                  let body = body else {
                return Just<AssistChatMessage?>(nil)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
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

    // MARK: - Private Methods
    /// Fetches the body of the course page and returns it as a string.
    private var body: AnyPublisher<String?, Error> {
        guard let courseID = courseID,
              let pageURL = pageURL else {
            return Just<String?>(nil)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return ReactiveStore(useCase: GetPage(context: .course(courseID), url: pageURL))
            .getEntities()
            .map { $0.first?.body }
            .eraseToAnyPublisher()
    }

    /// Given the document content, it returns a publisher that emits the summarized content.
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
}

extension CedarGenerateQuizMutation.QuizOutput {
    var quizItems: [AssistChatMessage.QuizItem] {
        data.generateQuiz.map {
            .init(
                question: $0.question,
                answers: $0.options,
                correctAnswerIndex: $0.result
            )
        }
    }
}
