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

public struct CourseSyncEntry: Equatable {
    public enum State: Codable, Equatable, Hashable {
        // CourseSyncEntryProgress relies on this order when it saves its' data.
        // Core Data Raw values:
        // loading = 0
        // error = 1
        // downloaded 2
        case loading(Float?), error, downloaded
    }

    let name: String

    /**
     The unique identifier of the sync entry in a form of "courses/:courseId". Doesn't correspond to the course ID on API. Use the `courseId` property if you need the API id.
     */
    let id: String
    var courseId: String { String(id.split(separator: "/").last ?? "") }

    var tabs: [CourseSyncEntry.Tab]
    var selectedTabs: [TabName] {
        tabs
            .filter { $0.selectionState == .selected || $0.selectionState == .partiallySelected }
            .map { $0.type }
    }

    var selectedTabsCount: Int {
        tabs.reduce(0) { partialResult, tab in
            partialResult + (tab.selectionState == .selected || tab.selectionState == .partiallySelected ? 1 : 0)
        }
    }

    var files: [CourseSyncEntry.File]
    var selectedFilesCount: Int {
        files.reduce(0) { partialResult, file in
            partialResult + (file.selectionState == .selected ? 1 : 0)
        }
    }

    var selectionCount: Int {
        (selectedFilesCount + selectedTabsCount) - (selectedFilesCount > 0 ? 1 : 0)
    }

    var isCollapsed: Bool = true
    var selectionState: ListCellView.SelectionState = .deselected
    var isEverythingSelected: Bool = false

    var state: State = .loading(nil)

    /// Total combined size of files and tabs in bytes.
    var totalSize: Int {
        let filesSize = files
            .reduce(0) { partialResult, file in
                partialResult + file.bytesToDownload
            }

        let tabsSize = tabs
            .filter { $0.type != TabName.files }
            .reduce(0) { partialResult, tab in
                partialResult + tab.bytesToDownload
            }

        return filesSize + tabsSize
    }

    /// Total size of course files in bytes.
    var totalFileSize: Int {
        files
            .reduce(0) { partialResult, file in
                partialResult + file.bytesToDownload
            }
    }

    /// When the total file size is greater than 0, display e.g 4 GB, otherwise return nil
    var totalSizeFormattedString: String? {
        totalSize > 0 ? totalSize.humanReadableFileSize : nil
    }

    /// Total combined size of selected files and tabs in bytes.
    var totalSelectedSize: Int {
        let filesSize = files
            .filter { $0.selectionState == .selected }
            .reduce(0) { partialResult, file in
                partialResult + file.bytesToDownload
            }

        let tabsSize = tabs
            .filter { $0.type != TabName.files }
            .filter { $0.selectionState == .selected }
            .reduce(0) { partialResult, tab in
                partialResult + tab.bytesToDownload
            }

        return filesSize + tabsSize
    }

    /// Total combined size of selected and downloaded files and tabs  in bytes.
    var totalDownloadedSize: Int {
        let filesSize = files
            .filter { $0.selectionState == .selected }
            .reduce(0) { partialResult, file in
                partialResult + file.bytesDownloaded
            }

        let tabsSize = tabs
            .filter { $0.type != TabName.files }
            .filter { $0.selectionState == .selected }
            .reduce(0) { partialResult, tab in
                partialResult + tab.bytesDownloaded
            }

        return filesSize + tabsSize
    }

    /// Total combined progress of selected file and tabs downloads, ranging from 0 to 1.
    var progress: Float {
        let totalFilesProgress = files
            .filter { $0.selectionState == .selected }
            .reduce(0 as Float) { partialResult, file in
                switch file.state {
                case .downloaded: return partialResult + 1
                case let .loading(progress): return partialResult + (progress ?? 0)
                case .error: return partialResult + 0
                }
            }

        let totalTabsProgress = tabs
            .filter { $0.type != TabName.files }
            .filter { $0.selectionState == .selected }
            .reduce(0 as Float) { partialResult, tab in
                switch tab.state {
                case .downloaded: return partialResult + 1
                case .loading: return partialResult + 0
                case .error: return partialResult + 0
                }
            }

        let selectedTabs = tabs
            .filter { $0.type != TabName.files }
            .filter { $0.selectionState == .selected }

        let selectedCount = (Float(selectedFilesCount) + Float(selectedTabs.count))
        guard selectedCount > 0 else { return 0 }
        return (totalFilesProgress + totalTabsProgress) / selectedCount
    }

    var hasError: Bool {
        let tabsError = tabs.contains { $0.state == .error }
        let filesError = files.contains { $0.state == .error }

        return state == .error || tabsError || filesError
    }

    var hasFileError: Bool {
        files.contains { $0.state == .error }
    }

    mutating func selectCourse(selectionState: ListCellView.SelectionState) {
        tabs.indices.forEach { tabs[$0].selectionState = selectionState }
        files.indices.forEach { files[$0].selectionState = selectionState }
        self.selectionState = selectionState
        isEverythingSelected = selectionState == .selected ? true : false
    }

    mutating func selectTab(id: String, selectionState: ListCellView.SelectionState) {
        tabs[id: id]?.selectionState = selectionState

        if tabs[id: id]?.type == .files {
            files.indices.forEach { files[$0].selectionState = selectionState }
        }

        // Selecting modules or grades will select every other tab because they are needed to compose modules/grades.
        if selectionState == .selected {
            if tabs[id: id]?.type == .modules || tabs[id: id]?.type == .grades {
                for (index, tab) in tabs.enumerated() where tab.type != .modules && tab.type != .grades {
                    tabs[index].selectionState = .selected
                }
            }
            // Deselecting a tab other than modules or grades will deselect modules and grades.
        } else if selectionState == .deselected {
            if tabs[id: id]?.type != .modules, tabs[id: id]?.type != .grades {
                for (index, tab) in tabs.enumerated() where tab.type == .modules || tab.type == .grades {
                    tabs[index].selectionState = .deselected
                }
            }
        }

        isEverythingSelected = (selectedTabsCount == tabs.count) && (selectedFilesCount == files.count)
        self.selectionState = selectedTabsCount > 0 ? .partiallySelected : .deselected
    }

    mutating func selectFile(id: String, selectionState: ListCellView.SelectionState) {
        files[id: id]?.selectionState = selectionState == .selected ? .selected : .deselected

        isEverythingSelected = (selectedTabsCount == tabs.count) && (selectedFilesCount == files.count)

        guard var fileTab = tabs.first(where: { $0.type == TabName.files }) else {
            return
        }
        fileTab.selectionState = selectedFilesCount > 0 ? .partiallySelected : .deselected
        tabs[id: fileTab.id] = fileTab

        self.selectionState = selectedTabsCount > 0 ? .partiallySelected : .deselected
    }

    mutating func updateCourseState(state: State) {
        self.state = state
    }

    mutating func updateTabState(id: String, state: State) {
        if let index = tabs.firstIndex(where: { $0.id == id }) {
            tabs[index].state = state
        }
    }

    mutating func updateFileState(id: String, state: State) {
        if let index = files.firstIndex(where: { $0.id == id }) {
            files[index].state = state
        }
    }
}

#if DEBUG

extension CourseSyncEntry.File {
    static func make(
        id: String,
        displayName: String,
        fileName: String = "File",
        url: URL = URL(string: "1")!,
        mimeClass: String = "jpg",
        updatedAt: Date? = nil,
        bytesToDownload: Int = 0,
        state: CourseSyncEntry.State = .loading(nil),
        selectionState: ListCellView.SelectionState = .deselected
    ) -> CourseSyncEntry.File {
        .init(
            id: id,
            displayName: displayName,
            fileName: fileName,
            url: url,
            mimeClass: mimeClass,
            updatedAt: updatedAt,
            state: state,
            selectionState: selectionState,
            bytesToDownload: bytesToDownload
        )
    }
}

#endif
