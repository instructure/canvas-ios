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

import Core
import Foundation

struct ScoreDetails {
    enum SortOption: String, CaseIterable {
        case dueDate
        case assignmentName

        var localizedTitle: String {
            switch self {
            case .dueDate:
                return String(localized: "Due Date", bundle: .horizon)
            case .assignmentName:
                return String(localized: "Assignment Name", bundle: .horizon)
            }
        }

        init(from string: String) {
            switch string {
            case String(localized: "Due Date", bundle: .horizon):
                self = .dueDate
            case String(localized: "Assignment Name", bundle: .horizon):
                self = .assignmentName
            default:
                fatalError()
            }
        }
    }

    let score: String
    let assignmentGroups: [HAssignmentGroup]
    let sortOption: SortOption

    var assignments: [HAssignment] {
        assignmentGroups.flatMap(\.assignments)
            .sorted { lhs, rhs in
                switch sortOption {
                case .dueDate:
                    return (lhs.dueAt ?? Date.distantFuture) < (rhs.dueAt ?? Date.distantFuture)
                case .assignmentName:
                    return lhs.name < rhs.name
                }
            }
    }
}
