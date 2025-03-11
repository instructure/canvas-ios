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

/// ChatBotActions are published to the  ChatBotInteractor. The Interactor reacts to the action and publishes one or more ChatBotResponses.
enum ChatBotAction {
    /// the user is chatting with the bot
    case chat(prompt: String = "", history: [ChatMessage] = [])

    /// the user has selected a chip while viewing a file
    case chipFile(chipOption: ChipOption, file: File, history: [ChatMessage])

    /// the user has selected a chip while viewing a page
    case chipPage(chipOption: ChipOption, title: String, body: String, history: [ChatMessage])

    /// the user is being shown a document (pdf, docx, etc) and asks something about
    case file(prompt: String, file: File, history: [ChatMessage])

    /// the user is reading a page and types in a prompt
    case page(prompt: String, title: String, body: String, history: [ChatMessage])

    /// The available chipOptions for the current action
    func chipOptions() -> [ChipOption] {
        switch self {
        case .page:
            return [.summarize, .keyTakeaways, .tellMeMore, .flashcards, .quiz]
        case .file:
            return [.summarize, .keyTakeaways, .tellMeMore, .flashcards]
        default:
            return []
        }
    }

    var promptContextString: String {
        switch self {
        case .page(_, let title, let body, _),
             .chipPage(_, let title, let body, _):
            return "This is the content the user is viewing. It includes a title and a body. Title: \(title) Body: \(body)"
        default:
            return ""
        }
    }
}
