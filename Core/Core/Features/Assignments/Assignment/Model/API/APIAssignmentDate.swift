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

// https://canvas.instructure.com/doc/api/assignments.html#AssignmentDate
public struct APIAssignmentDate: Codable, Equatable {
    let id: ID?
    let base: Bool?
    let title: String?
    let due_at: Date?
    let unlock_at: Date?
    let lock_at: Date?
}

#if DEBUG

extension APIAssignmentDate {
    public static func make(
        id: ID? = nil,
        base: Bool? = true,
        title: String? = nil,
        due_at: Date? = nil,
        unlock_at: Date? = nil,
        lock_at: Date? = nil
    ) -> APIAssignmentDate {
        return APIAssignmentDate(
            id: id,
            base: base,
            title: title,
            due_at: due_at,
            unlock_at: unlock_at,
            lock_at: lock_at
        )
    }
}

#endif
