//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

extension Tab {

    func toCellViewModel(attendanceToolID: String?, course: Course, cellSelectionAction: @escaping () -> Void) -> CourseDetailsCellViewModel {
        if let attendanceToolID = attendanceToolID, id == "context_external_tool_" + attendanceToolID {
            return AttendanceCellViewModel(tab: self, course: course, attendanceToolID: attendanceToolID, selectedCallback: cellSelectionAction)
        } else if type == .external, let url = url {
            return LTICellViewModel(tab: self, course: course, url: url)
        } else if name == .syllabus {
            return SyllabusCellViewModel(tab: self, course: course, selectedCallback: cellSelectionAction)
        } else {
            return GenericCellViewModel(tab: self, course: course, selectedCallback: cellSelectionAction)
        }
    }
}
