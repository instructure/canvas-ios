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
public struct CourseSyncItemSelection: Equatable {
    public enum SelectionType: String, Equatable {
        case course
        case file
        case tab
    }

    public let id: String
    public let selectionType: SelectionType
    public var encodedValue: String { "\(selectionType.rawValue)_\(id)" }

    public init(id: String, selectionType: SelectionType) {
        self.id = id
        self.selectionType = selectionType
    }

    public init?(encodedValue: String) {
        let components = encodedValue.split(separator: "_").map { String($0) }

        guard components.count == 2,
              let selectionType = SelectionType(rawValue: components[0])
        else {
            return nil
        }

        let id = components[1]
        self.id = id
        self.selectionType = selectionType
    }

    init?(courseSyncEntry: CourseSyncEntry) {
        guard courseSyncEntry.selectionState == .selected else {
            return nil
        }

        self.id = courseSyncEntry.id
        self.selectionType = .course
    }

    init?(courseSyncEntryTab: CourseSyncEntry.Tab) {
        guard courseSyncEntryTab.selectionState == .selected else {
            return nil
        }

        self.id = courseSyncEntryTab.id
        self.selectionType = .tab
    }

    init?(courseSyncEntryFile: CourseSyncEntry.File) {
        guard courseSyncEntryFile.selectionState == .selected else {
            return nil
        }

        self.id = courseSyncEntryFile.id
        self.selectionType = .file
    }

    func toCourseEntrySelection(from syncEntries: [CourseSyncEntry]) -> CourseEntrySelection? {
        switch selectionType {
        case .course:
            guard let index = syncEntries.firstIndex(where: { $0.id == id }) else { return nil }
            return .course(index)
        case .file:
            for (courseIndex, course) in syncEntries.enumerated() {
                guard let fileIndex = course.files.firstIndex(where: { $0.id == id }) else { continue }
                return .file(courseIndex, fileIndex)
            }
            return nil
        case .tab:
            for (courseIndex, course) in syncEntries.enumerated() {
                guard let tabIndex = course.tabs.firstIndex(where: { $0.id == id }) else { continue }
                return .tab(courseIndex, tabIndex)
            }
            return nil
        }
    }

    static func make(from syncEntries: [CourseSyncEntry]) -> [CourseSyncItemSelection] {
        syncEntries.reduce(into: []) { partialResult, syncEntry in
            if let courseSelection = CourseSyncItemSelection(courseSyncEntry: syncEntry) {
                partialResult.append(courseSelection)
                // If the whole course is selected then we don't need to map tabs or files
                return
            }

            partialResult.append(contentsOf: syncEntry.tabs.compactMap {
                CourseSyncItemSelection(courseSyncEntryTab: $0)
            })

            let isFilesTabSelected = syncEntry.tabs.contains(where: { $0.type == .files && $0.selectionState == .selected })

            if isFilesTabSelected {
                // If files tab is selected we don't need to map individial files
                return
            }

            partialResult.append(contentsOf: syncEntry.files.compactMap {
                CourseSyncItemSelection(courseSyncEntryFile: $0)
            })
        }
    }
}
