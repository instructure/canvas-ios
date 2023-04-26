//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import SwiftUI

extension CourseSyncSelectorViewModel {
    struct Item: Equatable, Hashable {
        enum TrailingIcon {
            case none
            case opened
            case closed
        }

        let isSelected: Bool
        let backgroundColor: Color
        let title: String
        let subtitle: String?
        let trailingIcon: TrailingIcon
        let isIndented: Bool
    }
}

// MARK: - Mapping From Model Objects

extension Array where Element == CourseSyncEntry {

    func makeViewModelItems() -> [CourseSyncSelectorViewModel.Item] {
        var items: [CourseSyncSelectorViewModel.Item] = []

        for course in self {
            items.append(course.makeViewModelItem())

            if !course.isCollapsed {
                for courseTab in course.tabs {
                    items.append(courseTab.makeViewModelItem())

                    if courseTab.type == .files, !courseTab.isCollapsed {
                        for file in course.files {
                            items.append(file.makeViewModelItem())
                        }
                    }
                }
            }
        }

        return items
    }
}

extension CourseSyncEntry {

    func makeViewModelItem() -> CourseSyncSelectorViewModel.Item {
        .init(isSelected: isSelected,
              backgroundColor: .backgroundLight,
              title: name,
              subtitle: nil,
              trailingIcon: isCollapsed ? .closed : .opened,
              isIndented: false)
    }
}

extension CourseSyncEntry.Tab {

    func makeViewModelItem() -> CourseSyncSelectorViewModel.Item {
        var trailingIcon = CourseSyncSelectorViewModel.Item.TrailingIcon.none

        if type == .files {
            trailingIcon = isCollapsed ? .closed : .opened
        }

        return .init(isSelected: isSelected,
                     backgroundColor: .backgroundLightest,
                     title: name,
                     subtitle: nil,
                     trailingIcon: trailingIcon,
                     isIndented: false)
    }
}

extension CourseSyncEntry.File {

    func makeViewModelItem() -> CourseSyncSelectorViewModel.Item {
        .init(isSelected: isSelected,
              backgroundColor: .backgroundLightest,
              title: name,
              subtitle: nil,
              trailingIcon: .none,
              isIndented: true)
    }
}
