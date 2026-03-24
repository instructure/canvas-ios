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

struct BusinessLogicAssignmentWeightEntitiesTests {

    // MARK: - GroupAssignment.init

    @Test
    func groupAssignment_succeeds_whenEligible() {
        let result = BusinessLogic.AssignmentWeight.GroupAssignment(
            isOmittedFromFinalGrade: false,
            pointsPossible: 100
        )
        #expect(result != nil)
        #expect(result?.pointsPossible == 100)
    }

    @Test
    func groupAssignment_treatsNilOmittedFlagAsNotOmitted() {
        let result = BusinessLogic.AssignmentWeight.GroupAssignment(
            isOmittedFromFinalGrade: nil,
            pointsPossible: 50
        )
        #expect(result != nil)
    }

    @Test
    func groupAssignment_returnsNil_whenOmittedFromFinalGrade() {
        let result = BusinessLogic.AssignmentWeight.GroupAssignment(
            isOmittedFromFinalGrade: true,
            pointsPossible: 100
        )
        #expect(result == nil)
    }

    @Test
    func groupAssignment_returnsNil_whenPointsPossibleIsNil() {
        let result = BusinessLogic.AssignmentWeight.GroupAssignment(
            isOmittedFromFinalGrade: false,
            pointsPossible: nil
        )
        #expect(result == nil)
    }

    @Test
    func groupAssignment_returnsNil_whenPointsPossibleIsZero() {
        let result = BusinessLogic.AssignmentWeight.GroupAssignment(
            isOmittedFromFinalGrade: false,
            pointsPossible: 0
        )
        #expect(result == nil)
    }

    @Test
    func groupAssignment_returnsNil_whenPointsPossibleIsNegative() {
        let result = BusinessLogic.AssignmentWeight.GroupAssignment(
            isOmittedFromFinalGrade: false,
            pointsPossible: -10
        )
        #expect(result == nil)
    }
}
