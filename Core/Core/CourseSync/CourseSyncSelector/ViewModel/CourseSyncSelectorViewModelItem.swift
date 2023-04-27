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
    struct Item: Hashable {
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

        var selectionToggled: (() -> Void)!

        static func == (lhs: CourseSyncSelectorViewModel.Item, rhs: CourseSyncSelectorViewModel.Item) -> Bool {
            lhs.isSelected == rhs.isSelected &&
            lhs.backgroundColor == rhs.backgroundColor &&
            lhs.title == rhs.title &&
            lhs.subtitle == rhs.subtitle &&
            lhs.trailingIcon == rhs.trailingIcon &&
            lhs.isIndented == rhs.isIndented
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(isSelected)
            hasher.combine(backgroundColor)
            hasher.combine(title)
            hasher.combine(subtitle)
            hasher.combine(trailingIcon)
            hasher.combine(isIndented)
        }
    }
}

// MARK: - Mapping From Model Objects

extension Array where Element == CourseSyncEntry {

    func makeViewModelItems(interactor: CourseSyncSelectorInteractor) -> [CourseSyncSelectorViewModel.Item] {
        var items: [CourseSyncSelectorViewModel.Item] = []

        for (courseIndex, course) in enumerated() {
            var courseItem = course.makeViewModelItem()
            courseItem.selectionToggled = {
                interactor.setSelected(selection: .course(courseIndex), isSelected: !courseItem.isSelected)
            }
            items.append(courseItem)

            if course.isCollapsed {
                continue
            }

            for (tabIndex, tab) in course.tabs.enumerated() {
                var tabItem = tab.makeViewModelItem()
                tabItem.selectionToggled = {
                    interactor.setSelected(selection: .tab(courseIndex, tabIndex), isSelected: !tabItem.isSelected)
                }
                items.append(tabItem)

                if tab.type == .files, !tab.isCollapsed {
                    for (fileIndex, file) in course.files.enumerated() {
                        var fileItem = file.makeViewModelItem()
                        fileItem.selectionToggled = {
                            interactor.setSelected(selection: .file(courseIndex, fileIndex), isSelected: !fileItem.isSelected)
                        }
                        items.append(fileItem)
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
