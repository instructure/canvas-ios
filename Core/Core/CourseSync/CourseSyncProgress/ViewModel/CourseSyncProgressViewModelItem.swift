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

extension CourseSyncProgressViewModel {

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
        let subtitle: String?
        var isCollapsed: Bool?
        let cellStyle: ListCellView.ListCellStyle
        let state: CourseSyncEntry.State

        fileprivate(set) var collapseDidToggle: (() -> Void)?
        fileprivate(set) var removeItemPressed: (() -> Void)?

        static func == (lhs: CourseSyncProgressViewModel.Item, rhs: CourseSyncProgressViewModel.Item) -> Bool {
            lhs.id == rhs.id &&
            lhs.title == rhs.title &&
            lhs.subtitle == rhs.subtitle &&
            lhs.isCollapsed == rhs.isCollapsed &&
            lhs.state == rhs.state
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(title)
            hasher.combine(subtitle)
            hasher.combine(isCollapsed)
            hasher.combine(state)
        }
    }
}

// MARK: - Mapping From Model Objects

extension Array where Element == CourseSyncEntry {

    func makeSyncProgressViewModelItems(interactor: CourseSyncProgressInteractor) -> [CourseSyncProgressViewModel.Cell] {
        var cells: [CourseSyncProgressViewModel.Cell] = []

        for (courseIndex, course) in enumerated() {
            var courseItem = course.makeSyncProgressViewModelItem()
            courseItem.collapseDidToggle = {
                interactor.setCollapsed(selection: .course(courseIndex), isCollapsed: !(courseItem.isCollapsed ?? false))
            }
            cells.append(.item(courseItem))

            if course.isCollapsed {
                continue
            }

            if course.tabs.isEmpty {
                cells.append(.empty(viewId: "course-\(course.id)-empty"))
                continue
            }

            for (tabIndex, tab) in course.tabs.enumerated() {
                var tabItem = tab.makeSyncProgressViewModelItem()
                tabItem.collapseDidToggle = {
                    interactor.setCollapsed(selection: .tab(courseIndex, tabIndex), isCollapsed: !(tabItem.isCollapsed ?? false))
                }
                cells.append(.item(tabItem))

                guard tab.type == .files, !tab.isCollapsed else {
                    continue
                }

                for file in course.files {
                    var fileItem = file.makeSyncProgressViewModelItem()
                    cells.append(.item(fileItem))
                }
            }
        }
        return cells
    }
}

extension CourseSyncEntry {

    func makeSyncProgressViewModelItem() -> CourseSyncProgressViewModel.Item {
        .init(id: "course-\(id)",
              title: name,
              subtitle: nil,
              isCollapsed: isCollapsed,
              cellStyle: .mainAccordionHeader,
              state: state)
    }
}

extension CourseSyncEntry.Tab {

    func makeSyncProgressViewModelItem() -> CourseSyncProgressViewModel.Item {
        .init(id: "courseTab-\(id)",
              title: name,
              subtitle: nil,
              isCollapsed: type == .files ? isCollapsed : nil,
              cellStyle: .listAccordionHeader,
              state: state)
    }
}

extension CourseSyncEntry.File {

    func makeSyncProgressViewModelItem() -> CourseSyncProgressViewModel.Item {
        .init(id: "file-\(id)",
              title: displayName,
              subtitle: nil,
              cellStyle: .listItem,
              state: state)
    }
}
