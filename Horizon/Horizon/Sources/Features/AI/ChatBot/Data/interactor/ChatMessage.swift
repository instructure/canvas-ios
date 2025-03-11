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

struct ChatMessage {
    /// The prompt that was sent to the AI. Not shown to the user
    let prompt: String

    /// The text shown to the user in the history. This may be different from the prompt sent to the AI
    let text: String

    /// Whether or not this came from the AI
    let isBot: Bool

    init(botResponse: String) {
        prompt = botResponse
        text = botResponse
        isBot = true
    }

    init(userResponse: String) {
        prompt = userResponse
        text = userResponse
        isBot = false
    }

    init(prompt: String, text: String) {
        self.prompt = prompt
        self.text = text

        isBot = false
    }
}
