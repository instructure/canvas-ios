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

import Testing
@testable import BusinessLogic

struct BusinessLogicAssignmentWeightTests {
    private let testee = BusinessLogic.AssignmentWeight.LogicLive()

    @Test
    func assignmentWeightInCourse_returnsNilWhenAssignmentIsNil() {
        let result = testee.assignmentWeightInCourse(
            assignment: nil,
            groupWeight: 50,
            assignmentsInGroup: [.make(pointsPossible: 100)]
        )
        #expect(result == nil)
    }

    @Test
    func assignmentWeightInCourse_returnsNilWhenGroupWeightIsNil() {
        let result = testee.assignmentWeightInCourse(
            assignment: .make(pointsPossible: 100),
            groupWeight: nil,
            assignmentsInGroup: [.make(pointsPossible: 100)]
        )
        #expect(result == nil)
    }

    @Test
    func assignmentWeightInCourse_returnsNilWhenGroupWeightIsZero() {
        let result = testee.assignmentWeightInCourse(
            assignment: .make(pointsPossible: 100),
            groupWeight: 0,
            assignmentsInGroup: [.make(pointsPossible: 100)]
        )
        #expect(result == nil)
    }

    @Test
    func assignmentWeightInCourse_returnsNilWhenGroupEmpty() {
        let result = testee.assignmentWeightInCourse(
            assignment: .make(pointsPossible: 100),
            groupWeight: 50,
            assignmentsInGroup: []
        )
        #expect(result == nil)
    }

    @Test
    func assignmentWeightInCourse_singleAssignment() {
        let result = testee.assignmentWeightInCourse(
            assignment: .make(pointsPossible: 100),
            groupWeight: 40,
            assignmentsInGroup: [.make(pointsPossible: 100)]
        )
        #expect(result == 0.4)
    }

    @Test
    func assignmentWeightInCourse_splitEquallyAcrossGroup() {
        let result = testee.assignmentWeightInCourse(
            assignment: .make(pointsPossible: 100),
            groupWeight: 40,
            assignmentsInGroup: [.make(pointsPossible: 100), .make(pointsPossible: 100)]
        )
        #expect(result == 0.2)
    }

    @Test
    func assignmentWeightInCourse_unequalPointsWeighsProportion() {
        // Assignment is 100 pts in a group of 300 pts total, group weight 60% → 60% * (100/300) = 20%
        let result = testee.assignmentWeightInCourse(
            assignment: .make(pointsPossible: 100),
            groupWeight: 60,
            assignmentsInGroup: [.make(pointsPossible: 100), .make(pointsPossible: 200)]
        )
        #expect(abs((result ?? 0) - 0.2) < 1e-10)
    }
}
