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

import Foundation

struct CourseSyncSelectorEntry {
    struct Tab {
        let id: String
        let name: String
        let type: TabName
        var isCollapsed: Bool = true
        var isSelected: Bool = false
    }

    struct File {
        let id: String
        let name: String
        let url: URL?
        var isSelected: Bool = false
    }

    let name: String
    let id: String

    var tabs: [Self.Tab]
    var selectedTabsCount: Int {
        tabs.reduce(0) { partialResult, tab in
            partialResult + (tab.isSelected ? 1 : 0)
        }
    }

    var files: [Self.File]
    var selectedFilesCount: Int {
        files.reduce(0) { partialResult, file in
            partialResult + (file.isSelected ? 1 : 0)
        }
    }

    var selectionCount: Int {
        (selectedFilesCount + selectedTabsCount) - (selectedFilesCount > 0 ? 1 : 0)
    }

    var isCollapsed: Bool = true
    var isSelected: Bool = false
    var isEverythingSelected: Bool = false

    mutating func selectCourse(isSelected: Bool) {
        tabs.indices.forEach { tabs[$0].isSelected = isSelected }
        files.indices.forEach { files[$0].isSelected = isSelected }
        self.isSelected = isSelected
        isEverythingSelected = isSelected
    }

    mutating func selectTab(index: Int, isSelected: Bool) {
        tabs[index].isSelected = isSelected

        if tabs[index].type == .files {
            files.indices.forEach { files[$0].isSelected = isSelected }
        }

        isEverythingSelected = (selectedTabsCount == tabs.count) && (selectedFilesCount == files.count)
        self.isSelected = selectedTabsCount > 0
    }

    mutating func selectFile(index: Int, isSelected: Bool) {
        files[index].isSelected = isSelected

        isEverythingSelected = (selectedTabsCount == tabs.count) && (selectedFilesCount == files.count)

        guard let fileTabIndex = tabs.firstIndex(where: { $0.type == TabName.files }) else {
            return
        }
        tabs[fileTabIndex].isSelected = selectedFilesCount > 0
        self.isSelected = selectedTabsCount > 0
    }
}
