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
    struct Item: Hashable, Identifiable {

        /** The SwiftUI view ID. */
        let id: String
        let title: String
        let subtitle: String?
        let progress: Float?
        var isCollapsed: Bool?
        let cellStyle: ListCellView.ListCellStyle
        let error: String?

        fileprivate(set) var collapseDidToggle: (() -> Void)?
        fileprivate(set) var removeItemPressed: (() -> Void)?

        static func == (lhs: CourseSyncProgressViewModel.Item, rhs: CourseSyncProgressViewModel.Item) -> Bool {
            lhs.id == rhs.id &&
            lhs.title == rhs.title &&
            lhs.subtitle == rhs.subtitle &&
            lhs.progress == rhs.progress &&
            lhs.isCollapsed == rhs.isCollapsed &&
            lhs.error == rhs.error
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(title)
            hasher.combine(subtitle)
            hasher.combine(progress)
            hasher.combine(isCollapsed)
            hasher.combine(error)
        }
    }
}

// MARK: - Mapping From Model Objects

extension Array where Element == CourseSyncProgressEntry {

    func makeViewModelItems(interactor: CourseSyncProgressInteractor) -> [CourseSyncProgressViewModel.Item] {
        var items: [CourseSyncProgressViewModel.Item] = []

        for (courseIndex, course) in enumerated() {
            var courseItem = course.makeViewModelItem()
            courseItem.collapseDidToggle = {
                interactor.setCollapsed(selection: .course(courseIndex), isCollapsed: !(courseItem.isCollapsed ?? false))
            }
            items.append(courseItem)

            if course.isCollapsed {
                continue
            }

            for (tabIndex, tab) in course.tabs.enumerated() {
                var tabItem = tab.makeViewModelItem()
                tabItem.collapseDidToggle = {
                    interactor.setCollapsed(selection: .tab(courseIndex, tabIndex), isCollapsed: !(tabItem.isCollapsed ?? false))
                }
                items.append(tabItem)

                guard tab.type == .files, !tab.isCollapsed else {
                    continue
                }

                for file in course.files {
                    let fileItem = file.makeViewModelItem()
                    items.append(fileItem)
                }
            }
        }
        return items
    }
}

extension CourseSyncProgressEntry {

    func makeViewModelItem() -> CourseSyncProgressViewModel.Item {
        .init(id: "course-\(id)",
              title: name,
              subtitle: nil,
              progress: progress,
              isCollapsed: isCollapsed,
              cellStyle: .mainAccordionHeader,
              error: error)
    }
}

extension CourseSyncProgressEntry.Tab {

    func makeViewModelItem() -> CourseSyncProgressViewModel.Item {
        .init(id: "courseTab-\(id)",
              title: name,
              subtitle: nil,
              progress: progress,
              isCollapsed: type == .files ? isCollapsed : nil,
              cellStyle: .listAccordionHeader,
              error: error)
    }
}

extension CourseSyncProgressEntry.File {

    func makeViewModelItem() -> CourseSyncProgressViewModel.Item {
        .init(id: "file-\(id)",
              title: name,
              subtitle: nil,
              progress: progress,
              cellStyle: .listItem,
              error: error)
    }
}
