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

public enum OfflineCheckboxState {
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

public struct OfflineCourseItem: Identifiable {
    public let id: String
    let name: String
    let size: String?
    var isExpanded: Bool = false
    var isSelected: Bool = false
    var downloadState: OfflineDownloadState = .idle
    var files: [OfflineFileItem]
    var hasSubItems: Bool { files.isNotEmpty }

    var selectionState: OfflineCheckboxState {
        guard !files.isEmpty else {
            return isSelected ? .checked : .unchecked
        }
        let selectedCount = files.filter { $0.isSelected }.count
        if selectedCount == files.count { return .checked }
        if selectedCount == 0 { return .unchecked }
        return .partial
    }

    var selectedFiles: [OfflineFileItem] { files.filter { $0.isSelected } }

    var sizeToDownload: Double { selectedFiles.map(\.sizeInBytes).reduce(0, +) }

    init(
        id: String,
        name: String,
        size: String? = nil,
        isExpanded: Bool = false,
        isSelected: Bool = false,
        subItems: [OfflineFileItem]
    ) {
        self.id = id
        self.name = name
        self.size = size
        self.isExpanded = isExpanded
        self.isSelected = isSelected
        self.files = subItems
    }

    init(from entity: CDHCourseSelection, offlineSyncItems: [String]) {
        self.id = entity.id
        self.name = entity.name
        self.size = entity.size
        let isCourseSynced = offlineSyncItems.contains(OfflineType.course(id: entity.id).path())
        self.isSelected = isCourseSynced
        self.files = entity.files.map { OfflineFileItem(from: $0, offlineSyncItems: offlineSyncItems) }
    }

    mutating func appFile(id: String, courseID: String) {
        files.append(
            .init(
                id: id,
                name: "",
                size: "",
                sizeInBytes: 0,
                isSelected: true,
                mimeClass: "",
                courseID: courseID
            )
        )
    }
}
