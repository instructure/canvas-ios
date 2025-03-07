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

class UpdateRedwoodNote: Codable, Equatable {
    public static func == (lhs: UpdateRedwoodNote, rhs: UpdateRedwoodNote) -> Bool {
        lhs.userText == rhs.userText &&
        lhs.reaction == rhs.reaction &&
        lhs.highlightData == rhs.highlightData
    }

    let userText: String
    let reaction: [String]?
    let highlightData: NotebookHighlight?

    enum CodingKeys: String, CodingKey {
        case userText, reaction, createdAt, highlightData
    }

    public init(
        userText: String,
        reaction: [String]?,
        highlightData: NotebookHighlight? = nil
    ) {
        self.userText = userText
        self.reaction = reaction
        self.highlightData = highlightData
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        userText = try container.decode(String.self, forKey: .userText)
        reaction = try container.decodeIfPresent([String].self, forKey: .reaction)

        do {
            highlightData = try container.decodeIfPresent(NotebookHighlight.self, forKey: .highlightData)
        } catch {
            highlightData = nil
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(userText, forKey: .userText)
        try container.encodeIfPresent(reaction, forKey: .reaction)

        if let highlightData = highlightData {
            try container.encode(highlightData, forKey: .highlightData)
        }
    }
}
