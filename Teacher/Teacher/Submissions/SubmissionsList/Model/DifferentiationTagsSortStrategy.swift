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

import Core
import Foundation

// MARK: - Differentiation Tags Sorting

enum DifferentiationTagsSortStrategy {

    static let sort: (CDUserGroup, CDUserGroup) -> Bool = { lhs, rhs in
        // First, separate single tags (ungrouped) from grouped tags
        let lhsIsSingle = lhs.isSingleTag
        let rhsIsSingle = rhs.isSingleTag

        // Single tags come first, then grouped tags
        if lhsIsSingle != rhsIsSingle {
            return lhsIsSingle
        }

        if lhsIsSingle && rhsIsSingle {
            // Both are single tags - sort alphabetically by name
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        } else {
            // Both are grouped tags - sort by group name first, then by tag name
            let groupComparison = lhs.parentGroupSet.name.localizedCaseInsensitiveCompare(rhs.parentGroupSet.name)
            if groupComparison != .orderedSame {
                return groupComparison == .orderedAscending
            }
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }
    }
}
