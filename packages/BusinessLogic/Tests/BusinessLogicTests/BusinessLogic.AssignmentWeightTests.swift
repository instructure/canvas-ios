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
    func noOpWhenEmpty() {
        let result = testee.applyDropRules(to: [], rules: .init(dropLowest: 1, dropHighest: 1, neverDropIds: []))
        #expect(result.isEmpty)
    }

    @Test
    func noOpWhenSingleItem() {
        let assignments = [(id: "a1", scorePercentage: 0.5)]
        let result = testee.applyDropRules(to: assignments, rules: .init(dropLowest: 1, dropHighest: 0, neverDropIds: []))
        #expect(result == ["a1"])
    }

    @Test
    func dropLowest() {
        let assignments = [
            (id: "a1", scorePercentage: 0.3),
            (id: "a2", scorePercentage: 0.7),
            (id: "a3", scorePercentage: 0.5)
        ]
        let result = testee.applyDropRules(to: assignments, rules: .init(dropLowest: 1, dropHighest: 0, neverDropIds: []))
        #expect(result.sorted() == ["a2", "a3"])
    }

    @Test
    func dropHighest() {
        let assignments = [
            (id: "a1", scorePercentage: 0.3),
            (id: "a2", scorePercentage: 0.7),
            (id: "a3", scorePercentage: 0.5)
        ]
        let result = testee.applyDropRules(to: assignments, rules: .init(dropLowest: 0, dropHighest: 1, neverDropIds: []))
        #expect(result.sorted() == ["a1", "a3"])
    }

    @Test
    func dropLowestAndHighest() {
        let assignments = [
            (id: "a1", scorePercentage: 0.2),
            (id: "a2", scorePercentage: 0.9),
            (id: "a3", scorePercentage: 0.5),
            (id: "a4", scorePercentage: 0.6)
        ]
        let result = testee.applyDropRules(to: assignments, rules: .init(dropLowest: 1, dropHighest: 1, neverDropIds: []))
        #expect(result.sorted() == ["a3", "a4"])
    }

    @Test
    func neverDropProtectsLowest() {
        let assignments = [
            (id: "a1", scorePercentage: 0.1),
            (id: "a2", scorePercentage: 0.8),
            (id: "a3", scorePercentage: 0.5)
        ]
        let result = testee.applyDropRules(to: assignments, rules: .init(dropLowest: 1, dropHighest: 0, neverDropIds: ["a1"]))
        #expect(result.sorted() == ["a1", "a2"])
    }

    @Test
    func neverDropProtectsHighest() {
        let assignments = [
            (id: "a1", scorePercentage: 0.3),
            (id: "a2", scorePercentage: 0.9),
            (id: "a3", scorePercentage: 0.5)
        ]
        let result = testee.applyDropRules(to: assignments, rules: .init(dropLowest: 0, dropHighest: 1, neverDropIds: ["a2"]))
        #expect(result.sorted() == ["a1", "a2"])
    }

    @Test
    func noOpWhenDropCountIsZero() {
        let assignments = [
            (id: "a1", scorePercentage: 0.3),
            (id: "a2", scorePercentage: 0.7)
        ]
        let result = testee.applyDropRules(to: assignments, rules: .init(dropLowest: 0, dropHighest: 0, neverDropIds: []))
        #expect(result.sorted() == ["a1", "a2"])
    }

    // MARK: - computeCourseGradeWeight

    @Test
    func computeCourseGradeWeight_returnsNilWhenEmpty() {
        let result = testee.computeCourseGradeWeight(
            assignmentPoints: 100,
            groupWeight: 50,
            assignments: [],
            rules: .init(dropLowest: 0, dropHighest: 0, neverDropIds: [])
        )
        #expect(result == nil)
    }

    @Test
    func computeCourseGradeWeight_simpleWeight() {
        let assignments = [
            BusinessLogic.AssignmentWeight.GroupAssignment(id: "a1", pointsPossible: 100, scorePercentage: 0.9, isGraded: true),
            BusinessLogic.AssignmentWeight.GroupAssignment(id: "a2", pointsPossible: 100, scorePercentage: 0.7, isGraded: true)
        ]
        let result = testee.computeCourseGradeWeight(
            assignmentPoints: 100,
            groupWeight: 40,
            assignments: assignments,
            rules: .init(dropLowest: 0, dropHighest: 0, neverDropIds: [])
        )
        #expect(result == 0.2)
    }

    @Test
    func computeCourseGradeWeight_dropsLowestGraded() {
        let assignments = [
            BusinessLogic.AssignmentWeight.GroupAssignment(id: "a1", pointsPossible: 100, scorePercentage: 0.4, isGraded: true),
            BusinessLogic.AssignmentWeight.GroupAssignment(id: "a2", pointsPossible: 100, scorePercentage: 0.9, isGraded: true),
            BusinessLogic.AssignmentWeight.GroupAssignment(id: "a3", pointsPossible: 100, scorePercentage: 0.0, isGraded: false)
        ]
        let result = testee.computeCourseGradeWeight(
            assignmentPoints: 100,
            groupWeight: 60,
            assignments: assignments,
            rules: .init(dropLowest: 1, dropHighest: 0, neverDropIds: [])
        )
        #expect(result == 0.3)
    }

    @Test
    func computeCourseGradeWeight_ungradedCountsInDenominator() {
        let assignments = [
            BusinessLogic.AssignmentWeight.GroupAssignment(id: "a1", pointsPossible: 100, scorePercentage: 0.8, isGraded: true),
            BusinessLogic.AssignmentWeight.GroupAssignment(id: "a2", pointsPossible: 100, scorePercentage: 0.0, isGraded: false)
        ]
        let result = testee.computeCourseGradeWeight(
            assignmentPoints: 100,
            groupWeight: 50,
            assignments: assignments,
            rules: .init(dropLowest: 0, dropHighest: 0, neverDropIds: [])
        )
        #expect(result == 0.25)
    }

    @Test
    func computeCourseGradeWeight_returnsNilWhenAllDropped() {
        let assignments = [
            BusinessLogic.AssignmentWeight.GroupAssignment(id: "a1", pointsPossible: 100, scorePercentage: 0.3, isGraded: true),
            BusinessLogic.AssignmentWeight.GroupAssignment(id: "a2", pointsPossible: 100, scorePercentage: 0.7, isGraded: true)
        ]
        let result = testee.computeCourseGradeWeight(
            assignmentPoints: 100,
            groupWeight: 50,
            assignments: assignments,
            rules: .init(dropLowest: 1, dropHighest: 1, neverDropIds: [])
        )
        #expect(result == nil)
    }
}
