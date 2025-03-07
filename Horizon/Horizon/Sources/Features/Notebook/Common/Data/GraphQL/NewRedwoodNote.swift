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

class NewRedwoodNote: UpdateRedwoodNote {
    public static func == (lhs: NewRedwoodNote, rhs: NewRedwoodNote) -> Bool {
        lhs.courseId == rhs.courseId &&
        lhs.objectId == rhs.objectId &&
        lhs.objectType == rhs.objectType &&
        (lhs as UpdateRedwoodNote) == (rhs as UpdateRedwoodNote)
    }

    let courseId: String
    let objectId: String
    let objectType: String

    enum CodingKeys: String, CodingKey {
        case courseId, objectId, objectType, userText, reaction, highlightData
    }

    init(
        courseId: String,
        objectId: String,
        objectType: String,
        userText: String,
        reaction: [String]?,
        highlightData: NotebookHighlight? = nil
    ) {
        self.courseId = courseId
        self.objectId = objectId
        self.objectType = objectType

        super.init(
            userText: userText,
            reaction: reaction,
            highlightData: highlightData
        )
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        courseId = try container.decode(String.self, forKey: .courseId)
        objectId = try container.decode(String.self, forKey: .objectId)
        objectType = try container.decode(String.self, forKey: .objectType)

        try super.init(from: decoder)
    }

    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(courseId, forKey: .courseId)
        try container.encode(objectId, forKey: .objectId)
        try container.encode(objectType, forKey: .objectType)
    }
}
