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

    public init?(_ string: String) {
        let components = string.split(separator: "_").map { String($0) }

        guard components.count == 2,
              let selectionType = SelectionType(rawValue: components[0])
        else {
            return nil
        }

        let id = components[1]
        self.id = id
        self.selectionType = selectionType
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
}