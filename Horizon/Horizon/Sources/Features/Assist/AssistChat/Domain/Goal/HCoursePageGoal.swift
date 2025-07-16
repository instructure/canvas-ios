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

class HCoursePageGoal: HCourseItemGoal {

    private var pageURL: String? {
        environment.pageURL.value
    }

    private let initialPrompt = String(localized: "How can I help you with this page?", bundle: .horizon)

    init(environment: AssistDataEnvironment, cedar: DomainService = DomainService(.cedar)) {
        super.init(
            initialPrompt: initialPrompt,
            environment: environment,
            cedar: cedar
        )
    }

    override
    func isRequested() -> Bool { courseID != nil && pageURL != nil }

    // MARK: - Private Methods

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

    private func summarizeContent() -> AnyPublisher<AssistChatMessage?, Error> {
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
