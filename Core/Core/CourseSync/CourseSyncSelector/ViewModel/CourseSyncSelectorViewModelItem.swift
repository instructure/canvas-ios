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

        /** The SwiftUI view ID. */
        let id: String
        let title: String
        let subtitle: String?
        let selectionState: ListCellView.SelectionState
        var isCollapsed: Bool?
        let cellStyle: ListCellView.ListCellStyle

        fileprivate(set) var selectionDidToggle: (() -> Void)?
        fileprivate(set) var collapseDidToggle: (() -> Void)?

        static func == (lhs: CourseSyncSelectorViewModel.Item, rhs: CourseSyncSelectorViewModel.Item) -> Bool {
            lhs.id == rhs.id &&
            lhs.title == rhs.title &&
            lhs.subtitle == rhs.subtitle &&
            lhs.selectionState == rhs.selectionState &&
            lhs.isCollapsed == rhs.isCollapsed
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(title)
            hasher.combine(subtitle)
            hasher.combine(selectionState)
            hasher.combine(isCollapsed)
        }
    }
}

// MARK: - Mapping From Model Objects

extension Array where Element == CourseSyncSelectorEntry {

    func makeViewModelItems(interactor: CourseSyncSelectorInteractor) -> [CourseSyncSelectorViewModel.Item] {
        var items: [CourseSyncSelectorViewModel.Item] = []

        for (courseIndex, course) in enumerated() {
            var courseItem = course.makeViewModelItem()
            courseItem.selectionDidToggle = {
                let selectionState: ListCellView.SelectionState = courseItem.selectionState == .selected || courseItem.selectionState == .partiallySelected ? .deselected : .selected
                interactor.setSelected(selection: .course(courseIndex), selectionState: selectionState)
            }
            courseItem.collapseDidToggle = {
                interactor.setCollapsed(selection: .course(courseIndex), isCollapsed: !(courseItem.isCollapsed ?? false))
            }
            items.append(courseItem)

            if course.isCollapsed {
                continue
            }

            for (tabIndex, tab) in course.tabs.enumerated() {
                var tabItem = tab.makeViewModelItem()
                tabItem.selectionDidToggle = {
                    let selectionState: ListCellView.SelectionState = tabItem.selectionState == .selected || tabItem.selectionState == .partiallySelected ? .deselected : .selected
                    interactor.setSelected(selection: .tab(courseIndex, tabIndex), selectionState: selectionState)
                }
                tabItem.collapseDidToggle = {
                    interactor.setCollapsed(selection: .tab(courseIndex, tabIndex), isCollapsed: !(tabItem.isCollapsed ?? false))
                }
                items.append(tabItem)

                guard tab.type == .files, !tab.isCollapsed else {
                    continue
                }

                for (fileIndex, file) in course.files.enumerated() {
                    var fileItem = file.makeViewModelItem()
                    fileItem.selectionDidToggle = {
                        interactor.setSelected(selection: .file(courseIndex, fileIndex), selectionState: fileItem.selectionState == .selected ? .deselected : .selected)
                    }
                    items.append(fileItem)
                }
            }
        }

        return items
    }
}

extension CourseSyncSelectorEntry {

    func makeViewModelItem() -> CourseSyncSelectorViewModel.Item {
        .init(id: "course-\(id)",
              title: name,
              subtitle: nil,
              selectionState: selectionState,
              isCollapsed: isCollapsed,
              cellStyle: .mainAccordionHeader)
    }
}

extension CourseSyncSelectorEntry.Tab {

    func makeViewModelItem() -> CourseSyncSelectorViewModel.Item {
        .init(id: "courseTab-\(id)",
              title: name,
              subtitle: nil,
              selectionState: selectionState,
              isCollapsed: type == .files ? isCollapsed : nil,
              cellStyle: .listAccordionHeader)
    }
}

extension CourseSyncSelectorEntry.File {

    func makeViewModelItem() -> CourseSyncSelectorViewModel.Item {
        .init(id: "file-\(id)",
              title: displayName,
              subtitle: nil,
              selectionState: selectionState,
              cellStyle: .listItem)
    }
}
