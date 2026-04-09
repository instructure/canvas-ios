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

struct OfflineSubItem: Identifiable {
    let id: String
    let name: String
    let size: String
    var isSelected: Bool
}

struct OfflineCourseItem: Identifiable {
    let id: String
    let name: String
    let size: String
    var isExpanded: Bool
    var isSelected: Bool
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

    // MARK: - Mock Data

    static let mockOfflineCourses: [OfflineCourseItem] = [
        .init(
            id: "course1",
            name: "Mathematics 101",
            size: "1.2 GB",
            isExpanded: true,
            isSelected: false,
            subItems: [
                OfflineSubItem(id: "file1", name: "Lecture 1.pdf", size: "50 MB", isSelected: true),
                OfflineSubItem(id: "file2", name: "Lecture 2.pdf", size: "60 MB", isSelected: true),
                OfflineSubItem(id: "file3", name: "Lecture 3.pdf", size: "55 MB", isSelected: true)
            ]
        ),
        OfflineCourseItem(
            id: "course2",
            name: "Physics 201",
            size: "900 MB",
            isExpanded: false,
            isSelected: false,
            subItems: [
                OfflineSubItem(id: "file1", name: "Chapter 1.mp4", size: "300 MB", isSelected: false),
                OfflineSubItem(id: "file2", name: "Chapter 2.mp4", size: "250 MB", isSelected: true)
            ]
        ),
        OfflineCourseItem(
            id: "course3",
            name: "History 101",
            size: "700 MB",
            isExpanded: false,
            isSelected: false,
            subItems: [
                OfflineSubItem(id: "file1", name: "Introduction.pdf", size: "40 MB", isSelected: false),
                OfflineSubItem(id: "file2", name: "Lecture Notes.pdf", size: "60 MB", isSelected: false)
            ]
        ),
        OfflineCourseItem(
            id: "course4",
            name: "Biology 101",
            size: "1.5 GB",
            isExpanded: true,
            isSelected: false,
            subItems: []
        )
    ]
}
