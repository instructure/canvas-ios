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

struct AssistQuizTool: AssistTool {

    // MARK: - Properties
    // swiftlint:disable line_length
    var description: String {
        """
            You are a teaching assistant creating quiz questions based on the provided content. Generate 15 multiple-choice questions with 4 options each, where one option is correct. Each question should be concise and clear, and the correct answer index is zero based. Ignore any HTML. Return the result in JSON format with no additional information. Here is the JSON format to use: [{question: String, options: [String], result: Int}]}]. For instance, if the question is, "What is the capital of France?", the JSON would look like this: [{question: "What is the capital of France?", options: ["Paris", "London", "Berlin", "Madrid"], result: 0}]. Make sure the JSON is valid.
        """
    }
    // swiftlint:enable line_length

    var name: String { "Quiz me on this material" }

    var isAvailable: Bool {
        state.courseID.value != nil &&
            (
                state.fileID.value != nil ||
                state.pageURL.value != nil ||
                state.textSelection.value != nil
            )
    }

    // MARK: - Dependencies
    private let cedar: DomainService
    private let pine: DomainService
    private let state: AssistState

    // MARK: - Init
    init(
        state: AssistState,
        pine: DomainService = DomainService(.pine),
        cedar: DomainService = DomainService(.cedar)
    ) {
        self.state = state
        self.pine = pine
        self.cedar = cedar
    }

    // MARK: - Inputs
    func execute(response: String?, history: [AssistChatMessage]) -> AnyPublisher<AssistChatMessage?, any Error> {
        guard let courseID = state.courseID.value else {
            return AssistChatMessage.nilResponse
        }

        if let pageURL = state.pageURL.value {
            return quiz(from: courseID, pageURL: pageURL)
        }

        if let fileID = state.fileID.value {
            return quiz(from: courseID, fileID: fileID)
        }

        if let textSelection = state.textSelection.value {
            return quiz(using: textSelection)
        }
        return AssistChatMessage.nilResponse
    }

    // MARK: - Private Methods
    private func quiz(from courseID: String, pageURL: String) -> AnyPublisher<AssistChatMessage?, any Error> {
        pageURL
            .pageBody(courseID: courseID)
            .flatMap { body in
                quiz(using: body ?? "")
            }
            .eraseToAnyPublisher()
    }

    private func quiz(from courseID: String, fileID: String) -> AnyPublisher<AssistChatMessage?, any Error> {
        pine
            .askARAGSingleQuestion(
                question: description,
                courseID: courseID,
                sourceID: fileID,
                sourceType: AssistChatInteractor.AssetType.wiki_page.rawValue
            )
            .tryMap { (response: String?) in
                guard let response = response,
                      let data = response.data(using: .utf8),
                      let quizOutput = try? JSONDecoder().decode(CedarGenerateQuizMutation.QuizOutput.self, from: data) else {
                    return nil
                }
                return AssistChatMessage(quizItems: quizOutput.quizItems)
            }
            .eraseToAnyPublisher()
    }

    private func quiz(using body: String) -> AnyPublisher<AssistChatMessage?, any Error> {
        cedar.api()
            .flatMap { api in
                api.makeRequest(CedarGenerateQuizMutation(context: body))
            }
            .map { (quizOutput: CedarGenerateQuizMutation.QuizOutput?, _) in
                AssistChatMessage(quizItems: quizOutput?.quizItems ?? [])
            }
            .eraseToAnyPublisher()
    }
}

private extension String {
    func pageBody(courseID: String) -> AnyPublisher<String?, any Error> {
        ReactiveStore(useCase: GetPage(context: .course(courseID), url: self))
            .getEntities()
            .map { $0.first?.body }
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
