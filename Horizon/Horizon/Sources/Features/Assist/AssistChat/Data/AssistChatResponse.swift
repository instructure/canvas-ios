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

    let isLoading: Bool

    /// Publishing an updated chat history. This happens when chatting with the bot
    init(
        _ message: AssistChatMessage,
        chatHistory: [AssistChatMessage] = [],
        isLoading: Bool = false,
        isFreeTextAvailable: Bool = true
    ) {
        self.chatHistory = chatHistory + [message]
        self.isLoading = isLoading
    }
}

/// Used when the user is asking a question about a course
extension AssistChatResponse {
    static func courseHelp(
        courseName: String,
        pageContext: AssistChatPageContext?,
        chatHistory: [AssistChatMessage] = []
    ) -> AssistChatResponse {
        .init(
            AssistChatMessage(staticResponse: .courseAssistance(courseName, pageContext: pageContext)),
            chatHistory: chatHistory
        )
    }
}

/// Used when the user is asked to select from one of their courses
extension AssistChatResponse {
    static func courseSelection(
        courses: [CourseNameAndID],
        chatHistory: [AssistChatMessage] = []
    ) -> AssistChatResponse {
        .init(
            AssistChatMessage(staticResponse: .selectACourse(courses)),
            chatHistory: chatHistory
        )
    }
}

/// Used when something isn't right, this is a generic response
extension AssistChatResponse {
    convenience init() {
        self.init(
            AssistChatMessage(
                botResponse: String(localized: "Thanks for visiting! Please check back later.")
            )
        )
    }
}

extension AssistChatResponse {
    static func review(chatHistory: [AssistChatMessage] = []) -> AssistChatResponse {
        .init(
            AssistChatMessage(
                staticResponse: .review
            ),
            chatHistory: chatHistory
        )
    }
}
