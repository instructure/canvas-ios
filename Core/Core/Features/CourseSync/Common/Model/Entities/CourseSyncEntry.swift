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

public struct CourseSyncID {
    private let value: String
    let apiBaseURL: URL?

    var id: String {
        value.localID
    }

    var env: AppEnvironment {
        .resolved(for: apiBaseURL)
    }

    var sessionId: String {
        env.currentSession?.uniqueID ?? ""
    }

    var asContext: Context { .course(id) }

    fileprivate init(value: String, apiBaseURL: URL?) {
        self.value = value
        self.apiBaseURL = apiBaseURL
    }
}

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
    let hasFrontPage: Bool
    var courseId: String { String(id.split(separator: "/").last ?? "") }
    var syncID: CourseSyncID { CourseSyncID(value: courseId, apiBaseURL: apiBaseURL) }

    /// List of available tabs coming from the API + a manually added tab named "Additional Content" that is responsible for tracking the download of hidden tabs and such.
    var tabs: [CourseSyncEntry.Tab]

    /// The number of tabs that are selectable by the user. When "Additional Content" is  added manually to the list, we need to substract 1 from the list count.
    var selectableTabsCount: Int {
        if tabs.contains(where: { $0.type == .additionalContent }) {
            return tabs.count - 1
        } else {
            return tabs.count
        }
    }

    /// Returns partially or fully selected tabs. "Additional Content" doesn't count.
    var selectedTabs: [TabName] {
        tabs
            .filter { $0.type != .additionalContent }
            .filter { $0.selectionState == .selected || $0.selectionState == .partiallySelected }
            .map { $0.type }
    }

    /// Returns the number of partially or fully selected tabs. "Additional Content" doesn't count.
    var selectedTabsCount: Int {
        selectedTabs.count
    }

    /// "Additional Content" and "Files" tabs don't count towards the final download size.
    var byteCountableSelectedTabs: [CourseSyncEntry.Tab] {
        tabs
            .filter { $0.type != TabName.files && $0.type != TabName.additionalContent }
            .filter { $0.selectionState == .selected }
    }

    var apiBaseURL: URL?
    var environment: AppEnvironment { .resolved(for: apiBaseURL) }

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
    var selectionState: OfflineListCellView.SelectionState = .deselected {
        didSet {
            if isFullContentSync, let index = tabs.firstIndex(where: { $0.type == .additionalContent}) {
                tabs[index].selectionState = .selected
            }
        }
    }
    var isFullContentSync: Bool {
        selectionState == .selected
    }

    var state: State = .loading(nil)

    /// Total combined size of files and tabs in bytes.
    var totalSize: Int {
        let filesSize = files
            .reduce(0) { partialResult, file in
                partialResult + file.bytesToDownload
            }

        let tabsSize = tabs
            .filter { $0.type != TabName.files && $0.type != TabName.additionalContent }
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

        let tabsSize = byteCountableSelectedTabs
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

        let tabsSize = byteCountableSelectedTabs
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

        let totalTabsProgress = byteCountableSelectedTabs
            .reduce(0 as Float) { partialResult, tab in
                switch tab.state {
                case .downloaded: return partialResult + 1
                case .loading: return partialResult + 0
                case .error: return partialResult + 0
                }
            }

        let selectedCount = (Float(selectedFilesCount) + Float(byteCountableSelectedTabs.count))
        guard selectedCount > 0 else { return 0 }
        return (totalFilesProgress + totalTabsProgress) / selectedCount
    }

    /// Returns **true** if any of the visible or hidden tabs or files failed to download.
    var hasError: Bool {
        let tabsError = tabs.contains { $0.state == .error }
        let filesError = files.contains { $0.state == .error }

        return state == .error || tabsError || filesError || hasAdditionalContentError
    }

    var hasFileError: Bool {
        files.contains { $0.state == .error }
    }

    var hasAdditionalContentError: Bool {
        additionalContentDownloadResults.contains { !$0 }
    }

    typealias IsDownloadSuccessful = Bool
    private(set) var additionalContentDownloadResults: [IsDownloadSuccessful] = []

    mutating func selectCourse(selectionState: OfflineListCellView.SelectionState) {
        tabs.indices.forEach { tabs[$0].selectionState = selectionState }
        files.indices.forEach { files[$0].selectionState = selectionState }
        self.selectionState = selectionState
    }

    mutating func selectTab(id: String, selectionState: OfflineListCellView.SelectionState) {
        tabs[id: id]?.selectionState = selectionState

        if tabs[id: id]?.type == .files {
            files.indices.forEach { files[$0].selectionState = selectionState }
        }

        if selectedTabsCount == selectableTabsCount, selectedFilesCount == files.count {
            self.selectionState = .selected
        } else if selectedTabsCount > 0 {
            self.selectionState = .partiallySelected
        } else {
            self.selectionState = .deselected
        }
    }

    mutating func selectFile(id: String, selectionState: OfflineListCellView.SelectionState) {
        files[id: id]?.selectionState = selectionState == .selected ? .selected : .deselected

        guard let fileTabId = tabs.first(where: { $0.type == TabName.files })?.id else {
            return
        }

        if selectedFilesCount == files.count {
            tabs[id: fileTabId]?.selectionState = .selected
        } else if selectedFilesCount > 0 {
            tabs[id: fileTabId]?.selectionState = .partiallySelected
        } else {
            tabs[id: fileTabId]?.selectionState = .deselected
        }

        if selectedTabsCount == selectableTabsCount, selectedFilesCount == files.count {
            self.selectionState = .selected
        } else if selectedTabsCount > 0 {
            self.selectionState = .partiallySelected
        } else {
            self.selectionState = .deselected
        }
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

    mutating func updateAdditionalContentResults(isSuccessful: Bool) {
        additionalContentDownloadResults.append(isSuccessful)
    }

    mutating func clearAdditionalContentResults() {
        additionalContentDownloadResults.removeAll()
    }
}

#if DEBUG

extension CourseSyncEntry {
    static func make(
        name: String = "entry",
        id: String = "entry-1",
        tabs: [CourseSyncEntry.Tab] = [],
        files: [CourseSyncEntry.File] = []
    ) -> CourseSyncEntry {
        CourseSyncEntry(
            name: name,
            id: id,
            hasFrontPage: false,
            tabs: tabs,
            files: files
        )
    }
}

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
        selectionState: OfflineListCellView.SelectionState = .deselected
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
