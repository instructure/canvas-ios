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

import Core
import Foundation

enum OfflineCheckboxState {
    case unchecked
    case partial
    case checked

    var accessibilityValue: String {
        switch self {
        case .checked: return String(localized: "Selected", bundle: .horizon)
        case .unchecked: return String(localized: "Not selected", bundle: .horizon)
        case .partial: return String(localized: "Partially selected", bundle: .horizon)
        }
    }
}

struct OfflineCourseItem: Identifiable {
    let id: String
    let name: String
    let size: String
    var isExpanded: Bool = false
    var isSelected: Bool = false
    var subItems: [OfflineSubItem]
    var hasSubItems: Bool { subItems.isNotEmpty }

    var selectionState: OfflineCheckboxState {
        guard !subItems.isEmpty else {
            return isSelected ? .checked : .unchecked
        }
        let selectedCount = subItems.filter { $0.isSelected }.count
        if selectedCount == subItems.count { return .checked }
        if selectedCount == 0 { return .unchecked }
        return .partial
    }

    var sizeToDownload: Double {
        guard subItems.isNotEmpty else {
            return 100_000
        }
        return subItems.map(\.sizeInBytes).reduce(0, +)
    }

    init(
        id: String,
        name: String,
        size: String,
        isExpanded: Bool,
        isSelected: Bool,
        subItems: [OfflineSubItem]
    ) {
        self.id = id
        self.name = name
        self.size = size
        self.isExpanded = isExpanded
        self.isSelected = isSelected
        self.subItems = subItems
    }

    init(from entity: CDHCourseSelection) {
        self.id = entity.id
        self.name = entity.name
        self.size = entity.size
        self.subItems = entity.files.map { .init(from: $0) }
    }
}
