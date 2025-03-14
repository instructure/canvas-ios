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

struct HAssignmentGroup: Identifiable {
    let id: String
    let name: String
    let groupWeight: Double?
    var groupWeightString: String? {
        if let groupWeight {
            return GradeFormatter.numberFormatter.string(
                from: NSNumber(value: groupWeight)
            )
        } else {
            return nil
        }
    }

    let assignments: [HAssignment]

    init(id: String, name: String, groupWeight: Double?, assignments: [HAssignment]) {
        self.id = id
        self.name = name
        self.groupWeight = groupWeight
        self.assignments = assignments
    }

    init(from entity: Core.AssignmentGroup) {
        self.id = entity.id
        self.name = entity.name
        self.groupWeight = entity.groupWeight?.doubleValue
        if let assignments = entity.assignments {
            self.assignments = Array(assignments).map { HAssignment(from: $0) }
        } else {
            self.assignments = []
        }
    }

    func update(assignments: [HAssignment]) -> HAssignmentGroup {
        HAssignmentGroup(
            id: id,
            name: name,
            groupWeight: groupWeight,
            assignments: assignments
        )
    }
}

extension Array where Element == HAssignmentGroup {
    private var groupWeightSum: Double {
        reduce(0) { result, group in
            result + (group.groupWeight ?? 0)
        }
    }

    var groupWeightSumString: String {
        GradeFormatter.numberFormatter.string(
            from: NSNumber(value: groupWeightSum)
        ) ?? ""
    }
}
