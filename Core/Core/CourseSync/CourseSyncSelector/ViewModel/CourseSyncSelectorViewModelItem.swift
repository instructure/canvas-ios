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
    enum Cell: Hashable, Identifiable {
        case empty(viewId: String)
        case item(Item)

        var id: String {
            switch self {
            case .empty(let viewId): return viewId
            case .item(let item): return item.id
            }
        }
    }

    struct Item: Hashable, Identifiable {

        /** The SwiftUI view ID. */
        let id: String
        let title: String
        var subtitle: String?
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

extension Array where Element == CourseSyncEntry {

    func makeViewModelItems(interactor: CourseSyncSelectorInteractor) -> [CourseSyncSelectorViewModel.Cell] {
        weak var interactor = interactor

        var cells: [CourseSyncSelectorViewModel.Cell] = []

        for course in self {
            var courseItem = course.makeViewModelItem()
            courseItem.selectionDidToggle = {
                let selectionState: ListCellView.SelectionState = course.selectionState == .selected || course.selectionState == .partiallySelected ? .deselected : .selected
                interactor?.setSelected(selection: .course(course.id), selectionState: selectionState)
            }
            courseItem.collapseDidToggle = {
                interactor?.setCollapsed(selection: .course(course.id), isCollapsed: !(course.isCollapsed))
            }
            cells.append(.item(courseItem))

            if course.isCollapsed {
                continue
            }

            if course.tabs.isEmpty {
                cells.append(.empty(viewId: "course-\(course.id)-empty"))
                continue
            }

            for tab in course.tabs {
                var tabItem = tab.makeViewModelItem()
                tabItem.selectionDidToggle = {
                    let selectionState: ListCellView.SelectionState = tab.selectionState == .selected || tab.selectionState == .partiallySelected ? .deselected : .selected
                    interactor?.setSelected(selection: .tab(course.id, tab.id), selectionState: selectionState)
                }
                tabItem.collapseDidToggle = {
                    interactor?.setCollapsed(selection: .tab(course.id, tab.id), isCollapsed: !(tab.isCollapsed))
                }

                guard tab.type == .files else {
                    tabItem.subtitle = tab.bytesToDownload.humanReadableFileSize
                    cells.append(.item(tabItem))
                    continue
                }

                tabItem.subtitle = course.totalFileSize.humanReadableFileSize
                cells.append(.item(tabItem))

                guard !tab.isCollapsed else {
                    continue
                }

                for file in course.files {
                    var fileItem = file.makeViewModelItem()
                    fileItem.selectionDidToggle = {
                        interactor?.setSelected(selection: .file(course.id, file.id), selectionState: file.selectionState == .selected ? .deselected : .selected)
                    }
                    cells.append(.item(fileItem))
                }
            }
        }

        return cells
    }
}

extension CourseSyncEntry {
    func makeViewModelItem() -> CourseSyncSelectorViewModel.Item {
        .init(id: id,
              title: name,
              subtitle: totalSizeFormattedString,
              selectionState: selectionState,
              isCollapsed: isCollapsed,
              cellStyle: .mainAccordionHeader)
    }
}

extension CourseSyncEntry.Tab {

    func makeViewModelItem() -> CourseSyncSelectorViewModel.Item {
        .init(id: id,
              title: name,
              subtitle: nil,
              selectionState: selectionState,
              isCollapsed: type == .files ? isCollapsed : nil,
              cellStyle: .listAccordionHeader)
    }
}

extension CourseSyncEntry.File {

    func makeViewModelItem() -> CourseSyncSelectorViewModel.Item {
        .init(id: id,
              title: displayName,
              subtitle: bytesToDownload.humanReadableFileSize,
              selectionState: selectionState,
              cellStyle: .listItem)
    }
}
