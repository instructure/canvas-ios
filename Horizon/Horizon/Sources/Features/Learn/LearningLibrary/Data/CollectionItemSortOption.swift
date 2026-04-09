//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

enum CollectionItemSortOption: CaseIterable {
    case mostRecent
    case leastRecent
    case nameAZ
    case nameZA

    var name: String {
        switch self {
        case .mostRecent: String(localized: "Most recent")
        case .leastRecent: String(localized: "Least recent")
        case .nameAZ: String(localized: "Name: A-Z")
        case .nameZA: String(localized: "Name: Z-A")
        }
    }

    var key: String {
        switch self {
        case .mostRecent: "MOST_RECENT"
        case .leastRecent: "LEAST_RECENT"
        case .nameAZ: "NAME_A_Z"
        case .nameZA: "NAME_Z_A"
        }
    }
}
