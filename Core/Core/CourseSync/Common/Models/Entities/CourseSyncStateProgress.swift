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

public struct CourseSyncStateProgress {
    let id: String
    let selection: CourseEntrySelection
    let state: CourseSyncEntry.State
    let entryID: String
    let tabID: String?
    let fileID: String?
    let progress: NSNumber?

    init(
        id: String,
        selection: CourseEntrySelection,
        state: CourseSyncEntry.State,
        entryID: String,
        tabID: String?,
        fileID: String?,
        progress: NSNumber?
    ) {
        self.id = id
        self.selection = selection
        self.state = state
        self.entryID = entryID
        self.tabID = tabID
        self.fileID = fileID
        self.progress = progress
    }

    init(from entity: CDCourseSyncStateProgress) {
        id = entity.id
        selection = entity.selection
        state = entity.state
        entryID = entity.entryID
        tabID = entity.tabID
        fileID = entity.fileID
        progress = entity.progress
    }
}

extension CourseSyncStateProgress {
    static func make(
        id: String = "1",
        selection: CourseEntrySelection = .course("1"),
        state: CourseSyncEntry.State = .loading(nil),
        entryID: String = "1",
        tabID: String? = nil,
        fileID: String? = nil,
        progress: NSNumber? = nil
    ) -> CourseSyncStateProgress {
        .init(
            id: id,
            selection: selection,
            state: state,
            entryID: entryID,
            tabID: tabID,
            fileID: fileID,
            progress: progress
        )
    }
}

extension Array where Element == CourseSyncStateProgress {
    /// Courses and file tabs are not syncable items so we should'n count them.
    func filterToCourses() -> Self {
        filter { entry in
            switch entry.selection {
            case .course: return true
            default: return false
            }
        }
    }
}
