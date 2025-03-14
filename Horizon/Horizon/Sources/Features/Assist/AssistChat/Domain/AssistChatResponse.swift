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

/// A response from the interactor
struct AssistChatResponse {

    // MARK: - Required

    let chatHistory: [AssistChatMessage]

    // MARK: - Optional

    let chipOptions: [AssistChipOption]?
    let flashCards: [FlashCard.FlashCard]?
    let isLoading: Bool
    let quizItem: QuizItem?

    init(chipOptions: [AssistChipOption], chatHistory: [AssistChatMessage] = []) {
        self.chipOptions = chipOptions
        self.chatHistory = chatHistory

        self.isLoading = false
        self.flashCards = nil
        self.quizItem = nil
    }

    /// The user has asked for FlashCards, so we're giving it to them
    init(flashCards: [FlashCard.FlashCard], chatHistory: [AssistChatMessage]) {
        self.flashCards = flashCards
        self.chatHistory = chatHistory

        self.isLoading = false
        self.chipOptions = nil
        self.quizItem = nil
    }

    /// The user has asked for a quiz, so we're giving it to them
    init(quizItem: QuizItem, chatHistory: [AssistChatMessage]) {
        self.chatHistory = chatHistory
        self.quizItem = quizItem

        self.isLoading = false
        self.chipOptions = nil
        self.flashCards = nil
    }

    /// Publishing an updated chat history. This happens when chatting with the bot
    init(
        message: AssistChatMessage,
        chipOptions: [AssistChipOption] = [],
        chatHistory: [AssistChatMessage] = [],
        isLoading: Bool = false
    ) {
        self.chatHistory = chatHistory + [message]
        self.chipOptions = chipOptions
        self.isLoading = isLoading

        self.flashCards = nil
        self.quizItem = nil
    }
}
