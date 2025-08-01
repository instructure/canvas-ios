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
class AssistCoursePageGoal: AssistCourseItemGoal {
    // MARK: - Private
    private var pageURL: String? {
        state.pageURL.value
    }

    private let initialPrompt = String(localized: "How can I help you with this page?", bundle: .horizon)

    // MARK: - Initializers
    init(state: AssistState, cedar: DomainService = DomainService(.cedar)) {
        super.init(
            state: state,
            initialPrompt: initialPrompt
        )
        sourceType = .wiki_page
    }

    // MARK: - Overrides

    override
    var isRequested: Bool { courseID != nil && pageURL != nil }

    override
    var sourceID: AnyPublisher<String?, any Error> {
        state.sourceID
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
}

extension AssistState {
    var sourceID: AnyPublisher<String?, any Error> {
        if let fileID = fileID.value {
            return Just(fileID)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        guard let courseID = courseID.value,
              let pageURL = pageURL.value else {
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
