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

struct AssistChipOption: Equatable {
    let chip: String
    let prompt: String?

    init(chip: String, prompt: String? = nil) {
        self.chip = chip
        self.prompt = prompt ?? chip
    }

    enum Default: Codable, CaseIterable {
        case summarize
        case keyTakeaways
        case tellMeMore
        case flashcards
        case quiz

        var rawValue: String {
            switch self {
            case .summarize:
                return String(localized: "Summarize", bundle: .horizon)
            case .keyTakeaways:
                return String(localized: "Key takeaways", bundle: .horizon)
            case .tellMeMore:
                return String(localized: "Tell me more", bundle: .horizon)
            case .flashcards:
                return String(localized: "Flash cards", bundle: .horizon)
            case .quiz:
                return String(localized: "Quiz", bundle: .horizon)
            }
        }
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

extension AssistChipOption: Codable, Hashable {
    enum CodingKeys: String, CodingKey {
        case chip, prompt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.chip = try container.decode(String.self, forKey: .chip)
        self.prompt = try container.decodeIfPresent(String.self, forKey: .prompt)
    }

    // Overload `==` for Equatable conformance
    static func == (lhs: AssistChipOption, rhs: AssistChipOption) -> Bool {
        return lhs.chip == rhs.chip && lhs.prompt == rhs.prompt
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(chip)
        hasher.combine(prompt)
    }
}
