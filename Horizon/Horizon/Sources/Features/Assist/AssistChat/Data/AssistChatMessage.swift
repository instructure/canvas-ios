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

import Foundation

/// A message returned from the interactor
struct AssistChatMessage {

    let id: UUID

    /// The prompt that was sent to the AI. Not shown to the user
    /// If set to null, then it is removed from the list of messages sent to the AI
    let prompt: String?

    /// The text shown to the user on screen. This may be different from the prompt sent to the AI
    let text: String?

    /// Whether or not this came from the AI
    let role: Role

    /// A list of options that the user can select from.
    let chipOptions: [AssistChipOption]?

    let flashCards: [AssistChatFlashCard]?

    let quizItems: [QuizItem]?

    init(botResponse: String, chipOptions: [AssistChipOption] = []) {
        self.init(
            role: .Assistant,
            prompt: botResponse,
            text: botResponse,
            chipOptions: chipOptions
        )
    }

    /// The user has asked for FlashCards
    init(flashCards: [AssistChatFlashCard]) {
        self.init(
            role: .Assistant,
            flashCards: flashCards
        )
    }

    /// The user has asked for a quiz
    init(quizItems: [QuizItem]) {
        self.init(
            role: .Assistant,
            quizItems: quizItems
        )
    }

    init(userResponse: String, prompt: String? = nil) {
        self.init(
            role: .User,
            prompt: prompt ?? userResponse,
            text: userResponse
        )
    }

    private init(
        role: Role,
        prompt: String? = nil,
        text: String? = nil,
        chipOptions: [AssistChipOption] = [],
        flashCards: [AssistChatFlashCard] = [],
        quizItems: [QuizItem]? = nil
    ) {
        self.id = UUID()
        self.role = role
        self.prompt = prompt
        self.text = text
        self.chipOptions = chipOptions
        self.flashCards = flashCards
        self.quizItems = quizItems
    }

    enum Role: String, Codable, Equatable {
        case Assistant
        case User
    }

    struct QuizItem: Codable, Equatable {
        let question: String
        let answers: [String]
        let correctAnswerIndex: Int
    }
}
