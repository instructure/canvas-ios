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
    }

    private let cedar: DomainService
    private let courseID: String
    private let pageURL: String
    private var options: [Option] {
        Option.allCases
    }
    private var chipOptions: [String] {
        options.map(\.rawValue)
    }

    init(courseID: String, pageURL: String, cedar: DomainService = DomainService(.cedar)) {
        self.courseID = courseID
        self.pageURL = pageURL
        self.cedar = cedar
    }

    override
    func execute(response: String?, history: [AssistChatMessage]) -> AnyPublisher<AssistChatMessage?, any Error> {
        guard let response = response, response.isNotEmpty else {
            return initialPrompt()
        }
        return choose(from: chipOptions, with: response, using: cedar)
            .flatMap { [weak self] chip in
                let nilResponse = Just(nil).setFailureType(to: Error.self).eraseToAnyPublisher()
                guard let self = self,
                      let chip = chip,
                      let option = self.options.first(where: { chip.contains($0.rawValue) }) else {
                        return nilResponse
                      }
                switch option {
                case .Quiz:
                    return self.quiz()
                default:
                    return nilResponse
                }
            }
            .eraseToAnyPublisher()
    }

    override
    func isRequested() -> Bool { true }

    // MARK: - Private Methods
    /// Makes a request to the cedar endpoint using the given prompt and returns an answer
//    private func basicChat(prompt: String) -> AnyPublisher<String, Error> {
//        cedar.api()
//            .flatMap { cedarApi in
//                cedarApi.makeRequest(
//                    CedarAnswerPromptMutation(
//                        prompt: prompt,
//                        document: CedarAnswerPromptMutation.DocumentInput.build(from: pageContext)
//                    )
//                )
//            }
//            .map { graphQlResponse, _ in graphQlResponse.data.answerPrompt }
//            .eraseToAnyPublisher()
//    }

    /// Fetches a page to use for AI context
    private var page: AnyPublisher<Page?, Error>? {
        ReactiveStore(useCase: GetPage(context: .course(courseID), url: pageURL))
            .getEntities()
            .map { $0.first }
            .eraseToAnyPublisher()
    }

    /// Calls the basic chat endpoint to generate flashcards
//    private func flashcards(page: Page) -> AnyPublisher<AssistChatResponse, Error> {
//        let chipPrompt = AssistChipOption(AssistChipOption.Default.flashcards, userShortName: userShortName).prompt
//        let pageContextPrompt = pageContext.prompt ?? ""
//        let prompt = "\(chipPrompt) \(pageContextPrompt) \(history.json)"
//        return basicChat(
//            prompt: prompt,
//            pageContext: pageContext
//        )
//        .compactMap { response in
//            .init(flashCards: AssistChatFlashCard.build(from: response) ?? [])
//        }
//        .eraseToAnyPublisher()
//    }

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

    /// Calls the cedar endpoint to generate a quiz
    private func quiz(prompt: String) -> AnyPublisher<AssistChatMessage, Error> {
        page.flatMap { [weak self] page in
            guard let self = self else {
                return
            }
            let prompt = page.
            return cedar.api()
                .flatMap { cedarApi in
                    return cedarApi.makeRequest(
                        CedarGenerateQuizMutation(context: prompt)
                    )
                    .compactMap { (quizOutput: CedarGenerateQuizMutation.QuizOutput?) in
                        quizOutput.map { quizOutput in
                                .init(
                                    quizItems: quizOutput.quizItems
                                )
                        }
                    }
                }
                .eraseToAnyPublisher()
        }
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
