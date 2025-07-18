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

public struct APICustomGradebookColumn: Codable, Equatable {
    public let id: String
    public let title: String
    public let position: Int?
    public let hidden: Bool?
    public let read_only: Bool?
    public let teacher_notes: Bool?

    public init(
        id: String,
        title: String,
        position: Int?,
        hidden: Bool?,
        read_only: Bool?,
        teacher_notes: Bool?
    ) {
        self.id = id
        self.title = title
        self.position = position
        self.hidden = hidden
        self.read_only = read_only
        self.teacher_notes = teacher_notes
    }
}

#if DEBUG

extension APICustomGradebookColumn {
    public static func make(
        id: String = "",
        title: String = "",
        position: Int? = nil,
        hidden: Bool? = nil,
        read_only: Bool? = nil,
        teacher_notes: Bool? = nil
    ) -> APICustomGradebookColumn {
        .init(
            id: id,
            title: title,
            position: position,
            hidden: hidden,
            read_only: read_only,
            teacher_notes: teacher_notes
        )
    }
}

#endif
