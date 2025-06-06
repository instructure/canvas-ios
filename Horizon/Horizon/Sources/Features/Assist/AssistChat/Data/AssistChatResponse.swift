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

import Core
import Foundation

/// A response from the interactor
class AssistChatResponse {

    // MARK: - Required

    let chatHistory: [AssistChatMessage]

    // MARK: - Optional

    let chipOptions: [AssistChipOption]?
    let flashCards: [AssistChatFlashCard]?
    let isLoading: Bool
    let quizItem: QuizItem?
    let isFreeTextAvailable: Bool

    init(chipOptions: [AssistChipOption], chatHistory: [AssistChatMessage] = []) {
        self.chipOptions = chipOptions
        self.chatHistory = chatHistory

        self.isLoading = false
        self.flashCards = nil
        self.quizItem = nil
        self.isFreeTextAvailable = true
    }

    /// The user has asked for FlashCards, so we're giving it to them
    init(flashCards: [AssistChatFlashCard], chatHistory: [AssistChatMessage]) {
        self.flashCards = flashCards
        self.chatHistory = chatHistory

        self.isLoading = false
        self.chipOptions = nil
        self.quizItem = nil
        self.isFreeTextAvailable = true
    }

    /// The user has asked for a quiz, so we're giving it to them
    init(quizItem: QuizItem, chatHistory: [AssistChatMessage]) {
        self.chatHistory = chatHistory
        self.quizItem = quizItem

        self.isLoading = false
        self.chipOptions = nil
        self.flashCards = nil
        self.isFreeTextAvailable = true
    }

    /// Publishing an updated chat history. This happens when chatting with the bot
    init(
        message: AssistChatMessage,
        chipOptions: [AssistChipOption] = [],
        chatHistory: [AssistChatMessage] = [],
        isLoading: Bool = false,
        isFreeTextAvailable: Bool = true
    ) {
        self.chatHistory = chatHistory + [message]
        self.chipOptions = chipOptions
        self.isLoading = isLoading
        self.isFreeTextAvailable = isFreeTextAvailable

        self.flashCards = nil
        self.quizItem = nil
    }

    struct QuizItem {
        let question: String
        let answers: [String]
        let correctAnswerIndex: Int
    }
}

/// Used when the user is asking a question about a course
extension AssistChatResponse {
    static func courseHelp(
        courseName: String,
        chatHistory: [AssistChatMessage] = []
    ) -> AssistChatResponse {
        let localResponse: AssistStaticLearnerResponse = .review
        return .init(
            message: AssistChatMessage(
                botResponse: String(
                    format: NSLocalizedString(
                        "How can I help today with the %@ course material?",
                        bundle: .horizon,
                        comment: "Assist chat initial response when only one course is available"
                    ),
                    courseName
                ),
            ),
            chipOptions: [
                .init(
                    chip: localResponse.chip,
                    localResponse: localResponse
                )
            ],
            chatHistory: chatHistory,
            isFreeTextAvailable: true
        )
    }
}

/// Used when the user is asked to select from one of their courses
extension AssistChatResponse {
    static func courseSelection(
        courses: [(name: String, id: String)],
        chatHistory: [AssistChatMessage] = []
    ) -> AssistChatResponse {
        .init(
            message: AssistChatMessage(
                botResponse: String(
                    localized: "Which of your courses would you like to discuss?",
                    bundle: .horizon
                )
            ),
            chipOptions: courses.map { course in
                let localResponse: AssistStaticLearnerResponse = .selectCourse(courseName: course.name, courseID: course.id)
                return .init(
                    chip: localResponse.chip,
                    localResponse: localResponse
                )
            },
            chatHistory: chatHistory,
            isFreeTextAvailable: false
        )
    }
}

/// Used when something isn't right, this is a generic response
extension AssistChatResponse {
    convenience init() {
        self.init(
            message: AssistChatMessage(
                botResponse: String(localized: "Thanks for visiting! Please check back later.")
            ),
            isFreeTextAvailable: false
        )
    }
}

extension AssistChatResponse {
    static func review(chatHistory: [AssistChatMessage] = []) -> AssistChatResponse {
        .init(
            message: AssistChatMessage(
                botResponse: String(
                    localized: "How would you like to review today?",
                    bundle: .horizon
                ),
            ),
            chipOptions: [
                .init(.flashcards),
                .init(.quiz)
            ],
            chatHistory: chatHistory,
            isFreeTextAvailable: false
        )
    }
}
