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

struct AssistChipOption: Codable, Hashable {
    let chip: String
    let prompt: String

    init(chip: String, prompt: String = "") {
        self.chip = chip
        self.prompt = prompt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        chip = try container.decode(String.self, forKey: .chip)
        prompt = try container.decode(String.self, forKey: .prompt)
    }

    enum Default: String, CaseIterable {
        case summarize = "Summarize"
        case keyTakeaways = "Key takeaways"
        case tellMeMore = "Tell me more"
        case flashcards = "Flash cards"
        case quiz = "Quiz"
    }

    // swiftlint:disable line_length
    init(_ option: Default, userShortName: String? = nil) {
        chip = option.rawValue

        var introduction = ""
        if let userShortName = userShortName {
            introduction = "You can address me as \(userShortName)."
        }
        switch option {
        case .summarize:
            prompt = "\(introduction) Give me a 1-2 paragraph summary of the content; don't use any information besides the provided content."
        case .keyTakeaways:
            prompt = "\(introduction) Give some key takeaways from this content; don't use any information besides the provided content. Return the response as a bulleted list."
        case .tellMeMore:
            prompt = "\(introduction) In 1-2 paragraphs, tell me more about this content."
        case .flashcards:
            prompt = "\(introduction) I'm creating flash cards. Give me 7 questions with answers based on the content. Return the result in JSON format like: [{question: '', answer: ''}, {question: '', answer: ''}] without any further description or text. Your flash cards should not refer to the format of the content, but rather the content itself."
        case .quiz:
            prompt = "Generate a quiz"
        }
    }
    // swiftlint:enable line_length
}
