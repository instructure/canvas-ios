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

public struct RedwoodNote: Codable {
    let id: String
    let courseId: String
    let objectId: String
    let objectType: String
    let userText: String
    let reaction: [String]?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, courseId, objectId, objectType, userText, reaction, createdAt
    }

    // Custom DateFormatter to handle the date format
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        courseId = try container.decode(String.self, forKey: .courseId)
        objectId = try container.decode(String.self, forKey: .objectId)
        objectType = try container.decode(String.self, forKey: .objectType)
        userText = try container.decode(String.self, forKey: .userText)
        reaction = try container.decodeIfPresent([String].self, forKey: .reaction)

        let dateString = try container.decode(String.self, forKey: .createdAt)
        if let date = RedwoodNote.dateFormatter.date(from: dateString) {
            createdAt = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .createdAt, in: container, debugDescription: "Date string does not match format expected by formatter.")
        }
    }
}
