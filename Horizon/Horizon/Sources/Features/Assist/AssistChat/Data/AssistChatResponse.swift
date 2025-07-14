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
struct AssistChatResponse {

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
