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

#if DEBUG

extension BusinessLogic.AssignmentWeight {

    public final class LogicMock: Logic {

        public var applyDropRulesReturnValue: [AssignmentID] = []
        public private(set) var applyDropRulesReceivedInvocations: [(
            assignments: [(id: AssignmentID, scorePercentage: Double)],
            rules: DropRules
        )] = []

        public init() {}

        public func applyDropRules(
            to assignments: [(id: AssignmentID, scorePercentage: Double)],
            rules: DropRules
        ) -> [AssignmentID] {
            applyDropRulesReceivedInvocations.append((assignments, rules))
            return applyDropRulesReturnValue
        }

        public var computeCourseGradeWeightReturnValue: Double? = nil
        public private(set) var computeCourseGradeWeightReceivedInvocations: [(
            assignmentPoints: Double,
            groupWeight: Double,
            assignments: [GroupAssignment],
            rules: DropRules
        )] = []

        public func computeCourseGradeWeight(
            assignmentPoints: Double,
            groupWeight: Double,
            assignments: [GroupAssignment],
            rules: DropRules
        ) -> Double? {
            computeCourseGradeWeightReceivedInvocations.append((assignmentPoints, groupWeight, assignments, rules))
            return computeCourseGradeWeightReturnValue
        }
    }
}

#endif
