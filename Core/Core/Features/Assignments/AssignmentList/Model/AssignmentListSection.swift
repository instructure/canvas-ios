//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import SwiftUI

/// Section model to be used in `AssignmentListView`.
/// Its `Row` enum provides models for various kinds of item cells.
struct AssignmentListSection: Equatable, Identifiable {
    let id: String
    let title: String
    let rows: [Row]

    enum Row: Equatable, Identifiable {
        /// Used on `AssignmentListScreen` when displayed in Student app
        case student(StudentAssignmentListItem)
        /// Used on `AssignmentListScreen` when displayed in Teacher app
        case teacher(TeacherAssignmentListItem)
        /// Used on `GradeListScreen` when displayed in Student or Parent apps
        /// The model type is common with the `student` case, but the cell using it is slightly different.
        case gradeListRow(StudentAssignmentListItem)

        var id: String {
            switch self {
            case .student(let row): row.id
            case .teacher(let row): row.id
            case .gradeListRow(let row): row.id
            }
        }
    }
}
