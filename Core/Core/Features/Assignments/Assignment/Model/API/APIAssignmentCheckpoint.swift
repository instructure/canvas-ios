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

public struct APIAssignmentCheckpoint: Codable, Equatable {
    let tag: String
    let name: String
    let points_possible: Double?
    let due_at: Date?
    let unlock_at: Date?
    let lock_at: Date?
    let only_visible_to_overrides: Bool?
    let overrides: [APIAssignmentOverride]? // populated only when requested by Teacher
}

#if DEBUG

extension APIAssignmentCheckpoint {
    public static func make(
        tag: String = "",
        name: String = "",
        points_possible: Double? = nil,
        due_at: Date? = nil,
        unlock_at: Date? = nil,
        lock_at: Date? = nil,
        only_visible_to_overrides: Bool? = nil,
        overrides: [APIAssignmentOverride]? = nil
    ) -> APIAssignmentCheckpoint {
        return APIAssignmentCheckpoint(
            tag: tag,
            name: name,
            points_possible: points_possible,
            due_at: due_at,
            unlock_at: unlock_at,
            lock_at: lock_at,
            only_visible_to_overrides: only_visible_to_overrides,
            overrides: overrides
        )
    }
}

#endif
