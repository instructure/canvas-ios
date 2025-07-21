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

struct AssistChipOption: Equatable {
    let chip: String
    let prompt: String?

    init(chip: String, prompt: String? = nil) {
        self.chip = chip
        self.prompt = prompt ?? chip
    }
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
