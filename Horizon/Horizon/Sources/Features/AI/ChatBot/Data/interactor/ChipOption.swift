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

enum ChipOption: String, CaseIterable {
    case summarize = "Summarize"
    case keyTakeaways = "Key takeaways"
    case tellMeMore = "Tell me more"
    case flashcards = "Flashcards"
    case quiz = "Quiz"

    func prompt(action: ChatBotAction, userShortName: String) -> String {
        let introduction = "You can address me as \(userShortName)."
        switch self {
        case .summarize:
            return "\(introduction) Give me a 1-2 paragraph summary of the content; don't use any information besides the provided content. Return the response as HTML paragraphs. \(action.promptContextString)"
        case .keyTakeaways:
            return "\(introduction) Give some key takeaways from this content; don't use any information besides the provided content. Return the response as an HTML unordered list. \(action.promptContextString)"
        case .tellMeMore:
            return "\(introduction) In 1-2 paragraphs, tell me more about this content. Return the response as HTML paragraphs. \(action.promptContextString)"
        case .flashcards:
            return "\(introduction) Here is the content from a course in html format, i need 7 questions with answers, like a quiz, based on the content, give back in jason format like: {data: [{question: '', answer: ''}, {question: '', answer: ''}, ...]} without any further description or text. \(action.promptContextString)"
        case .quiz:
            return "\(introduction). \(action.promptContextString)"
        }
    }
}
