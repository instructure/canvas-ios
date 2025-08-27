//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

public struct APIAssignmentGroup: Codable, Equatable {
    let id: ID
    let name: String
    let position: Int
    let group_weight: Double?
    var assignments: [APIAssignment]?
}

#if DEBUG
extension APIAssignmentGroup {
    public static func make(
        id: ID = "1",
        name: String = "Assignment Group A",
        position: Int = 1,
        group_weight: Double? = nil,
        assignments: [APIAssignment]? = nil
        ) -> APIAssignmentGroup {
        return APIAssignmentGroup(
            id: id,
            name: name,
            position: position,
            group_weight: group_weight,
            assignments: assignments
        )
    }
}
#endif
