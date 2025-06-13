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

/// These are predefined responses from which a learner can select
enum AssistStaticLearnerResponse {
    case answerQuestion
    case selectCourse(courseName: String, courseID: String, pageContext: AssistChatPageContext?)
    case flashCards
    case quiz

    /// Based on a selected learner response, compose a response for the AI Assistant
    func assistChatResponse(chatHistory: [AssistChatMessage]) -> AssistChatResponse? {
        let newChatHistory = chatHistory + [AssistChatMessage(userResponse: chip)]
        switch self {
        case .answerQuestion:
            return AssistChatResponse(
                AssistChatMessage(
                    botResponse: String(localized: "What is your question today?", bundle: .horizon)
                ),
                chatHistory: newChatHistory
            )
        case .selectCourse(let courseName, _, let pageContext):
            return .courseHelp(
                courseName: courseName,
                pageContext: pageContext,
                chatHistory: newChatHistory
            )
        default:
            return nil
        }
    }

    /// Returns a localized string for the chip option
    var chip: String {
        switch self {
        case .answerQuestion:
            return String(localized: "Ask a question", bundle: .horizon)
        case .selectCourse(let courseName, _, _):
            return courseName
        case .flashCards:
            return String(localized: "Create flash cards", bundle: .horizon)
        case .quiz:
            return String(localized: "Quiz me", bundle: .horizon)
        }
    }

    var service: DomainService.Option? {
        switch self {
        case .quiz, .flashCards:
            return .cedar
        default:
            return nil
        }
    }
}
