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

public class UpdateRedwoodNote: Codable, Equatable {
    public static func == (lhs: UpdateRedwoodNote, rhs: UpdateRedwoodNote) -> Bool {
        lhs.userText == rhs.userText &&
        lhs.reaction == rhs.reaction &&
        lhs.highlightKey == rhs.highlightKey &&
        lhs.highlightedText == rhs.highlightedText &&
        lhs.length == rhs.length &&
        lhs.startIndex == rhs.startIndex
    }

    let userText: String
    let reaction: [String]?
    var highlightData: [String: Any]?

    var highlightKey: String? {
        get {
            highlightData?["highlightKey"] as? String
        }
        set {
            setHighlightData(key: "highlightKey", value: newValue)
        }
    }

    var highlightedText: String? {
        get {
            highlightData?["highlightedText"] as? String
        }
        set {
            setHighlightData(key: "highlightedText", value: newValue)
        }
    }

    var length: Int? {
        get {
            highlightData?["length"] as? Int
        }
        set {
            setHighlightData(key: "length", value: newValue)
        }
    }

    var startIndex: Int? {
        get {
            highlightData?["startIndex"] as? Int
        }
        set {
            setHighlightData(key: "startIndex", value: newValue)
        }
    }

    private func setHighlightData(key: String, value: Any?) {
        var highlightData = self.highlightData ?? [:]
        if let value = value {
            highlightData[key] = value
        } else {
            highlightData.removeValue(forKey: key)
        }
        self.highlightData = highlightData
    }

    enum CodingKeys: String, CodingKey {
        case userText, reaction, createdAt, highlightData
    }

    public init(
        userText: String,
        reaction: [String]?,
        highlightKey: String?,
        highlightedText: String?,
        length: Int?,
        startIndex: Int?
    ) {
        self.userText = userText
        self.reaction = reaction
        self.highlightKey = highlightKey
        self.highlightedText = highlightedText
        self.length = length
        self.startIndex = startIndex
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        userText = try container.decode(String.self, forKey: .userText)
        reaction = try container.decodeIfPresent([String].self, forKey: .reaction)

        let highlightDataString = try container.decodeIfPresent(String.self, forKey: .highlightData)
        if let highlightDataString = highlightDataString,
            let highlightData = try JSONSerialization.jsonObject(with: Data(highlightDataString.utf8)) as? [String: Any] {
            self.highlightData = highlightData
        } else {
            self.highlightData = nil
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(userText, forKey: .userText)
        try container.encodeIfPresent(reaction, forKey: .reaction)

        if let highlightData = highlightData,
            let data = try? JSONSerialization.data(withJSONObject: highlightData, options: []),
            let highlightDataString = String(data: data, encoding: .utf8) {
            try container.encode(highlightDataString, forKey: .highlightData)
        }
    }
}
