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

/// The AssistChatPageContext is used to capture the context of the page that the user is interacting with.
/// This can be sent with the prompt for tha AI to have more context when generating responses.
struct AssistChatPageContext {
    let title: String?
    let body: String?

    let format: Format?
    let name: String?
    let source: String?

    let chips: [AssistChipOption.Default]

    init() {
        title = nil
        body = nil
        format = nil
        name = nil
        source = nil
        chips = []
    }

    init(title: String, body: String) {
        self.title = title
        self.body = body

        format = nil
        name = nil
        source = nil

        chips = [.summarize, .keyTakeaways, .tellMeMore, .flashcards, .quiz]
    }

    init(format: Format, name: String, source: String) {
        self.format = format
        self.name = name
        self.source = source

        title = nil
        body = nil

        chips = [.summarize, .keyTakeaways, .tellMeMore, .flashcards]
    }

    var prompt: String? {
        if let title = title, let body = body {
            return "This is a document with the title '\(title)' and the body '\(body)'"
        }
        if let format = format, let name = name, let source = source {
            return "This is a file with the format '\(format)', the name '\(name)', and the source '\(source)'"
        }
        return nil
    }
}
