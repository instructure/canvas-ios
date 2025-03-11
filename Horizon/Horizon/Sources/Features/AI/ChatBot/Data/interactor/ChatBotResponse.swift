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

struct ChatBotResponse {

    // MARK: - Required

    let chatHistory: [ChatMessage]

    // MARK: - Optional

    let chipOptions: [String]?
    let flashCards: [FlashCard.FlashCard]?
    let quizItems: [QuizItem]?

    /// The user will have chip options to choose from
    /// This only happens when there is no history
    init(chipOptions: [String]) {
        self.chipOptions = chipOptions

        self.chatHistory = []
        self.flashCards = nil
        self.quizItems = nil
    }

    /// The user has asked for FlashCards, so we're giving it to them
    init(flashCards: [FlashCard.FlashCard], chatHistory: [ChatMessage]) {
        self.flashCards = flashCards
        self.chatHistory = chatHistory

        self.chipOptions = nil
        self.quizItems = nil
    }

    /// The user has asked for a quiz, so we're giving it to them
    init(quizItems: [QuizItem], chatHistory: [ChatMessage]) {
        self.chatHistory = chatHistory
        self.quizItems = quizItems

        self.chipOptions = nil
        self.flashCards = nil
    }

    /// Publishing an updated chat history. This happens when chatting with the bot
    init(message: ChatMessage, chatHistory: [ChatMessage] = []) {
        self.chatHistory = chatHistory + [message]

        self.chipOptions = nil
        self.flashCards = nil
        self.quizItems = nil
    }

    /// The last response from the bot
//    var response: String? {
//        chatHistory.last?.text
//    }
}
