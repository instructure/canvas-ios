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

/**
 This entity is saved to the user's defaults and represents a single item selection in the offline sync selection screen.
 */
public typealias CourseSyncItemSelection = String

extension CourseSyncItemSelection {

    func toCourseEntrySelection(from syncEntries: [CourseSyncEntry]) -> CourseEntrySelection? {
        for course in syncEntries {
            if course.id == self {
                return .course(course.id)
            }

            if let tab = course.tabs.first(where: { $0.id == self }) {
                return .tab(course.id, tab.id)
            }

            if let file = course.files.first(where: { $0.id == self }) {
                return .file(course.id, file.id)
            }
        }

        return nil
    }

    static func make(from syncEntries: [CourseSyncEntry]) -> [CourseSyncItemSelection] {
        syncEntries.reduce(into: []) { partialResult, syncEntry in
            if syncEntry.selectionState == .selected {
                partialResult.append(syncEntry.id)
                // If the whole course is selected then we don't need to map tabs or files
                return
            }

            let selectedTabs = syncEntry.tabs.filter { $0.selectionState == .selected }
            partialResult.append(contentsOf: selectedTabs.map { $0.id })

            let isFilesTabSelected = syncEntry.tabs.contains(where: { $0.type == .files && $0.selectionState == .selected })

            if isFilesTabSelected {
                // If files tab is selected we don't need to map individial files
                return
            }

            let selectedFiles = syncEntry.files.filter { $0.selectionState == .selected }
            partialResult.append(contentsOf: selectedFiles.map { $0.id })
        }
    }
}
