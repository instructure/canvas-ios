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
    struct Item: Hashable, Identifiable {
        enum TrailingIcon {
            case none
            case opened
            case closed
        }

        /** The SwiftUI view ID. */
        let id: String
        let isSelected: Bool
        let backgroundColor: Color
        let title: String
        let subtitle: String?
        let trailingIcon: TrailingIcon
        let isIndented: Bool
        var isCollapsed: Bool { trailingIcon == .closed }

        fileprivate(set) var selectionDidToggle: (() -> Void)?
        fileprivate(set) var collapseDidToggle: (() -> Void)?

        static func == (lhs: CourseSyncSelectorViewModel.Item, rhs: CourseSyncSelectorViewModel.Item) -> Bool {
            lhs.id == rhs.id &&
            lhs.isSelected == rhs.isSelected &&
            lhs.backgroundColor == rhs.backgroundColor &&
            lhs.title == rhs.title &&
            lhs.subtitle == rhs.subtitle &&
            lhs.trailingIcon == rhs.trailingIcon &&
            lhs.isIndented == rhs.isIndented
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
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
            courseItem.selectionDidToggle = {
                interactor.setSelected(selection: .course(courseIndex), isSelected: !courseItem.isSelected)
            }
            courseItem.collapseDidToggle = {
                interactor.setCollapsed(selection: .course(courseIndex), isCollapsed: !courseItem.isCollapsed)
            }
            items.append(courseItem)

            if course.isCollapsed {
                continue
            }

            for (tabIndex, tab) in course.tabs.enumerated() {
                var tabItem = tab.makeViewModelItem()
                tabItem.selectionDidToggle = {
                    interactor.setSelected(selection: .tab(courseIndex, tabIndex), isSelected: !tabItem.isSelected)
                }
                tabItem.collapseDidToggle = {
                    interactor.setCollapsed(selection: .tab(courseIndex, tabIndex), isCollapsed: !tabItem.isCollapsed)
                }
                items.append(tabItem)

                if tab.type == .files, !tab.isCollapsed {
                    for (fileIndex, file) in course.files.enumerated() {
                        var fileItem = file.makeViewModelItem()
                        fileItem.selectionDidToggle = {
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
        .init(id: "course-\(id)",
              isSelected: isSelected,
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

        return .init(id: "courseTab-\(id)",
                     isSelected: isSelected,
                     backgroundColor: .backgroundLightest,
                     title: name,
                     subtitle: nil,
                     trailingIcon: trailingIcon,
                     isIndented: false)
    }
}

extension CourseSyncEntry.File {

    func makeViewModelItem() -> CourseSyncSelectorViewModel.Item {
        .init(id: "file-\(id)",
              isSelected: isSelected,
              backgroundColor: .backgroundLightest,
              title: name,
              subtitle: nil,
              trailingIcon: .none,
              isIndented: true)
    }
}
