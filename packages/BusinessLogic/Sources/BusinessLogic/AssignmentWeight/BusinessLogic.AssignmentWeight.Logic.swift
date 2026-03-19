//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

extension BusinessLogic.AssignmentWeight {

    public protocol Logic {

        /// Computes what fraction of the final course grade a single assignment contributes,
        /// based solely on the group's weight and each assignment's share of the group's total points.
        ///
        /// Both `assignment` and `groupWeight` are optional so callers can pass API values directly
        /// without unwrapping; `nil` or ineligible values result in `nil` being returned.
        /// - Returns: Weight fraction, or `nil` if `assignment` or `groupWeight` is nil,
        ///   `groupWeight` is not positive, or the group's total points is zero.
        func assignmentWeightInCourse(
            assignment: GroupAssignment?,
            groupWeight: Double?,
            assignmentsInGroup: [GroupAssignment]
        ) -> Double?
    }

    public struct LogicLive: Logic, Sendable {

        public init() {}

        public func assignmentWeightInCourse(
            assignment: GroupAssignment?,
            groupWeight: Double?,
            assignmentsInGroup: [GroupAssignment]
        ) -> Double? {
            guard let assignment, let groupWeight, groupWeight > 0 else { return nil }
            let totalGroupPoints = assignmentsInGroup.reduce(0.0) { $0 + $1.pointsPossible }
            guard totalGroupPoints > 0 else { return nil }
            return (groupWeight / 100) * (assignment.pointsPossible / totalGroupPoints)
        }
    }
}
