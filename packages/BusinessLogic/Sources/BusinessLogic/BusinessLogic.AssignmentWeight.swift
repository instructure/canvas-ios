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

extension BusinessLogic {

    public enum AssignmentWeight {

        public typealias AssignmentID = String

        public struct DropRules {
            public let dropLowest: Int
            public let dropHighest: Int
            public let neverDropIds: [AssignmentID]

            public init(dropLowest: Int, dropHighest: Int, neverDropIds: [AssignmentID]) {
                self.dropLowest = dropLowest
                self.dropHighest = dropHighest
                self.neverDropIds = neverDropIds
            }
        }

        public struct GroupAssignment {
            public let id: AssignmentID
            public let pointsPossible: Double
            public let scorePercentage: Double
            public let isGraded: Bool

            public init(id: AssignmentID, pointsPossible: Double, scorePercentage: Double, isGraded: Bool) {
                self.id = id
                self.pointsPossible = pointsPossible
                self.scorePercentage = scorePercentage
                self.isGraded = isGraded
            }
        }

        public protocol Logic {

            /// Returns the IDs of assignments that survive after applying Canvas drop rules.
            ///
            /// - Parameters:
            ///   - assignments: Candidates with their score expressed as a percentage (score / pointsPossible).
            ///   - rules: Drop rules specifying how many lowest/highest to remove and which IDs are protected.
            /// - Returns: IDs of assignments that were **not** dropped.
            func applyDropRules(
                to assignments: [(id: AssignmentID, scorePercentage: Double)],
                rules: DropRules
            ) -> [AssignmentID]

            /// Computes what fraction of the final course grade a single assignment contributes,
            /// taking into account group weight, drop rules, and graded/ungraded split.
            ///
            /// - Parameters:
            ///   - assignmentPoints: `pointsPossible` of the assignment being weighted.
            ///   - groupWeight: The assignment group's weight as a percentage (0–100).
            ///   - assignments: All assignments in the group that are eligible (not omitted, points > 0).
            ///   - rules: Drop rules to apply to graded assignments before computing the denominator.
            /// - Returns: Weight fraction, or `nil` if the group is empty or totalPoints is zero.
            func computeCourseGradeWeight(
                assignmentPoints: Double,
                groupWeight: Double,
                assignments: [GroupAssignment],
                rules: DropRules
            ) -> Double?
        }

        public struct LogicLive: Logic, Sendable {

            public init() {}

            public func applyDropRules(
                to assignments: [(id: AssignmentID, scorePercentage: Double)],
                rules: DropRules
            ) -> [AssignmentID] {
                if assignments.count <= 1 { return assignments.map { $0.id } }

                let neverDropSet = Set(rules.neverDropIds)
                let eligibleForDropSorted = assignments
                    .filter { !neverDropSet.contains($0.id) }
                    .sorted { $0.scorePercentage < $1.scorePercentage }

                var toDrop = Set<AssignmentID>()

                if rules.dropLowest > 0 {
                    eligibleForDropSorted.prefix(rules.dropLowest).forEach { toDrop.insert($0.id) }
                }

                if rules.dropHighest > 0 {
                    eligibleForDropSorted.suffix(rules.dropHighest).forEach { toDrop.insert($0.id) }
                }

                return assignments.compactMap { toDrop.contains($0.id) ? nil : $0.id }
            }

            public func computeCourseGradeWeight(
                assignmentPoints: Double,
                groupWeight: Double,
                assignments: [GroupAssignment],
                rules: DropRules
            ) -> Double? {
                guard !assignments.isEmpty else { return nil }

                let graded = assignments.filter { $0.isGraded }
                let ungraded = assignments.filter { !$0.isGraded }

                let survivingGradedIds = Set(applyDropRules(
                    to: graded.map { (id: $0.id, scorePercentage: $0.scorePercentage) },
                    rules: rules
                ))
                let countingGraded = graded.filter { survivingGradedIds.contains($0.id) }
                let countingAssignments = countingGraded + ungraded

                guard !countingAssignments.isEmpty else { return nil }
                let totalPoints = countingAssignments.reduce(0.0) { $0 + $1.pointsPossible }
                guard totalPoints > 0 else { return nil }
                return (groupWeight / 100) * (assignmentPoints / totalPoints)
            }
        }
    }
}
