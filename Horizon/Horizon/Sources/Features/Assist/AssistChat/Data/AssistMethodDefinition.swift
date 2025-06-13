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

class GenerateQuiz: AssistMethodDefinition {
    enum GenerateQuizError: Error {
        case failedToGenerateQuiz
    }

    var methodName: String = "generateQuiz"
    var description: String = "Given the ID"
    var parameters: [String: String] = [
        "courseID": "The ID of the course to which the quiz belongs. This is a required parameter.",
        "pageURL": "The path of the page from which to generate the quiz. This is a required parameter.",
        "numberOfQuestions": "Number of questions to generate. This is not required.",
        "numberOfOptionsPerQuestion": "Number of options per question. This is not required."
    ]

    private let cedarDomainService: DomainService

    private var subscriptions: Set<AnyCancellable> = []

    init(cedarDomainService: DomainService = DomainService(.cedar)) {
        self.cedarDomainService = cedarDomainService
    }

    func handler(_ response: String, chatHistory: [AssistChatMessage]) -> AnyPublisher<AssistChatResponse, Error> {
        guard let courseID = extract(parameter: "courseID", from: response),
              let pageUrl = extract(parameter: "pageURL", from: response) else {
            return Fail(error: GenerateQuizError.failedToGenerateQuiz).eraseToAnyPublisher()
        }
        return ReactiveStore(useCase: GetPage(context: .course(courseID), url: pageUrl))
            .getEntities()
            .map { AssistChatPageContext(title: $0.first?.title ?? "", body: $0.first?.body ?? "") }
            .replaceError(with: AssistChatPageContext())
            .flatMap { [weak self] pageContext in
                self?.quiz(pageContext: pageContext, chatHistory: chatHistory) ??
                    Fail(error: GenerateQuizError.failedToGenerateQuiz).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func quiz(
        pageContext: AssistChatPageContext,
        chatHistory: [AssistChatMessage]
    ) -> AnyPublisher<AssistChatResponse, Error> {
        cedarDomainService
            .api()
            .flatMap { cedarApi in
                guard let prompt = pageContext.prompt else {
                    return Just(
                        AssistChatResponse(
                            AssistChatMessage(botResponse: "Sorry, I couldn't generate a quiz right now. Try again later."),
                            chatHistory: chatHistory
                        )
                    )
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
                }
                return cedarApi
                    .makeRequest(CedarGenerateQuizMutation(context: prompt))
                    .map { quizOutput in
                        guard let quizItem = quizOutput?.quizItems.first else {
                            return AssistChatResponse(
                                AssistChatMessage(
                                    botResponse: "Sorry, I'm unable to generate a quiz for you at this time."
                                ),
                                chatHistory: chatHistory
                            )
                        }
                        return AssistChatResponse(
                            AssistChatMessage(quizItem: quizItem),
                            chatHistory: chatHistory
                        )
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

protocol AssistMethodDefinition {
    var methodName: String { get }
    var description: String { get }
    var parameters: [String: String] { get }
    func handler(_:String, chatHistory: [AssistChatMessage]) -> AnyPublisher<AssistChatResponse, Error>
}

extension AssistMethodDefinition {
    /// methodName - The name of the method. For instance "generateQuiz"
    /// response - The response from the AI that contains the method call. For example: generateQuiz(courseID: "123", pageURL: "/courses/123/pages/sample-page", numberOfQuestions: 5, numberOfOptionsPerQuestion: 4)
    func isMatch(for methodName: String, from response: String) -> Bool {
        let regexPattern = "\(methodName)\\(([^)]*)\\)"
        let regex = try? NSRegularExpression(pattern: regexPattern, options: [])
        return regex?.numberOfMatches(
            in: response,
            options: [],
            range: NSRange(location: 0, length: response.count)
        ) == 1
    }
    /// parameter - The name of the parameter. For instance "courseID"
    /// response - The response from the AI that contains the method call. For example: generateQuiz(courseID: "123", pageURL: "/courses/123/pages/sample-page", numberOfQuestions: 5, numberOfOptionsPerQuestion: 4)
    func extract(parameter: String, from response: String) -> String? {
        let regexPattern = "\(parameter)\\s*:\\s*\"([^\"]*)\""
        let regex = try? NSRegularExpression(pattern: regexPattern, options: [])
        guard let match = regex?.firstMatch(
            in: response,
            options: [],
            range: NSRange(location: 0, length: response.count)
        ),
              let range = Range(match.range(at: 1), in: response) else {
            return nil
        }
        return String(response[range])
    }
}
