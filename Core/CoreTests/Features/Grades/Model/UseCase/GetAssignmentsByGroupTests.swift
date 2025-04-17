//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
@testable import Core
import TestsFoundation
import XCTest

class GetAssignmentsByGroupTests: CoreTestCase {

    func testCacheKeyNotDifferentiatesGradingPeriods() {
        var useCase = GetAssignmentsByGroup(courseID: "1", gradingPeriodID: nil)
        XCTAssertEqual(useCase.cacheKey, "courses/1/assignment_groups")
        useCase = GetAssignmentsByGroup(courseID: "1", gradingPeriodID: "1")
        XCTAssertEqual(useCase.cacheKey, "courses/1/assignment_groups")
    }

    func testFetchesAssignmentsWhenThereAreNoGradingPeriods() {
        let groups: [APIAssignmentGroup] = [
            .make(id: "1", name: "TestGroup", position: 1, assignments: [
                .make(assignment_group_id: "1", grading_type: .points, id: "1", name: "Points", position: 1)
            ])
        ]
        let groupsRequest = GetAssignmentGroupsRequest(
            courseID: "tc",
            gradingPeriodID: nil,
            perPage: 100
        )
        api.mock(groupsRequest, value: groups)
        api.mock(GetGradingPeriods(courseID: "tc"), value: [])

        let testee = GetAssignmentsByGroup(courseID: "tc")
        let store = environment.subscribe(testee)

        // WHEN
        XCTAssertFinish(store.refreshWithFuture())

        // THEN
        XCTAssertEqual(store.numberOfSections, 1)
        XCTAssertEqual(store.numberOfObjects(inSection: 0), 1)
        guard let assignment = store[IndexPath(row: 0, section: 0)] else { return XCTFail() }
        XCTAssertEqual(assignment.name, "Points")
        XCTAssertEqual(assignment.assignmentGroup?.name, "TestGroup")
        XCTAssertEqual(assignment.gradingPeriod, nil)
    }

    private func mockMultipleGradingPeriods(hideInGradeBook: Bool = false) {
        // Grading period 1 assignment and group
        let groups1: [APIAssignmentGroup] = [
            .make(id: "1", name: "TestGroup1", position: 1, assignments: [
                .make(assignment_group_id: "1", grading_type: .points, id: "1", name: "Points1", position: 1, hide_in_gradebook: hideInGradeBook)
            ])
        ]
        let groupsRequest1 = GetAssignmentGroupsRequest(
            courseID: "tc",
            gradingPeriodID: "g1",
            perPage: 100
        )
        let group1Called = expectation(description: "group1Called")
        api.mock(groupsRequest1) { _ in
            group1Called.fulfill()
            return (groups1, nil, nil)
        }

        // Grading period 2 assignment and group
        let groups2: [APIAssignmentGroup] = [
            .make(id: "2", name: "TestGroup2", position: 2, assignments: [
                .make(assignment_group_id: "2", grading_type: .points, id: "2", name: "Points2", position: 1)
            ])
        ]
        let groupsRequest2 = GetAssignmentGroupsRequest(
            courseID: "tc",
            gradingPeriodID: "g2",
            perPage: 100
        )
        let group2Called = expectation(description: "group2Called")
        api.mock(groupsRequest2) { _ in
            group2Called.fulfill()
            return (groups2, nil, nil)
        }

        // Grading period nil assignment and group
        let groups3: [APIAssignmentGroup] = [
            .make(id: "3", name: "TestGroup3", position: 3, assignments: [])
        ]
        let groupsRequest3 = GetAssignmentGroupsRequest(
            courseID: "tc",
            gradingPeriodID: nil,
            perPage: 100
        )
        let group3Called = expectation(description: "group3Called")
        api.mock(groupsRequest3) { _ in
            group3Called.fulfill()
            return (groups3, nil, nil)
        }

        let gradingPeriodsCalled = expectation(description: "gradingPeriodsCalled")
        api.mock(GetGradingPeriodsRequest(courseID: "tc")) { _ in
            gradingPeriodsCalled.fulfill()
            return ([
                .make(id: "g1", title: "GP1"),
                .make(id: "g2", title: "GP2")
             ], nil, nil)
        }
    }

    func testFetchesAssignmentsForEachGradingPeriod() {
        mockMultipleGradingPeriods()
        let testee = GetAssignmentsByGroup(courseID: "tc")
        let store = environment.subscribe(testee)

        // WHEN
        XCTAssertFinish(store.refreshWithFuture())

        // THEN
        waitForExpectations(timeout: 1)
        XCTAssertEqual(store.numberOfSections, 2)

        XCTAssertEqual(store.numberOfObjects(inSection: 0), 1)
        guard let assignment1 = store[IndexPath(row: 0, section: 0)] else { return XCTFail() }
        XCTAssertEqual(assignment1.name, "Points1")
        XCTAssertEqual(assignment1.assignmentGroup?.name, "TestGroup1")
        XCTAssertEqual(assignment1.gradingPeriod?.title, "GP1")

        XCTAssertEqual(store.numberOfObjects(inSection: 1), 1)
        guard let assignment2 = store[IndexPath(row: 0, section: 1)] else { return XCTFail() }
        XCTAssertEqual(assignment2.name, "Points2")
        XCTAssertEqual(assignment2.assignmentGroup?.name, "TestGroup2")
        XCTAssertEqual(assignment2.gradingPeriod?.title, "GP2")
    }

    func testFetchesAssignmentsForEachGradingPeriodWhenHideGradeIsFalse() {
        // GIVEN
        mockMultipleGradingPeriods(hideInGradeBook: true)
        let testee = GetAssignmentsByGroup(courseID: "tc")
        let store = environment.subscribe(testee)

        // WHEN
        XCTAssertFinish(store.refreshWithFuture())

        // THEN
        waitForExpectations(timeout: 1)
        XCTAssertEqual(store.numberOfSections, 1)
    }

    func testFetchesAssignmentsForEachGradingPeriodAndReturnsAssignmentsForAGradingPeriod() {
        mockMultipleGradingPeriods()
        let testee = GetAssignmentsByGroup(courseID: "tc", gradingPeriodID: "g1")
        let store = environment.subscribe(testee)

        // WHEN
        XCTAssertFinish(store.refreshWithFuture())

        // THEN
        waitForExpectations(timeout: 1)
        XCTAssertEqual(store.numberOfSections, 1)

        XCTAssertEqual(store.numberOfObjects(inSection: 0), 1)
        guard let assignment1 = store[IndexPath(row: 0, section: 0)] else { return XCTFail() }
        XCTAssertEqual(assignment1.name, "Points1")
        XCTAssertEqual(assignment1.assignmentGroup?.name, "TestGroup1")
        XCTAssertEqual(assignment1.gradingPeriod?.title, "GP1")
    }

    func testInvalidSectionOrderException() {
        let groups: [APIAssignmentGroup] = [
            .make(id: "9732", name: "Test Assignment Group", position: 1, assignments: [APIAssignment.make(assignment_group_id: "9732", id: "63603", name: "File Upload", position: 1)]),
            .make(id: "9734", name: "Middle Group", position: 2, assignments: [APIAssignment.make(assignment_group_id: "9734", id: "63604", name: "File Upload 2", position: 1)]),
            .make(id: "9733", name: "Test Assignment Group", position: 3, assignments: [APIAssignment.make(assignment_group_id: "9733", id: "63606", name: "File Upload 3", position: 1)])
        ]
        let result = [GetAssignmentsByGroup.AssignmentGroupsByGradingPeriod(gradingPeriod: nil, assignmentGroups: groups)]

        let getAssignmentGroupsUseCase = GetAssignmentsByGroup(courseID: "20783")
        getAssignmentGroupsUseCase.write(response: result, urlResponse: nil, to: databaseClient)

        // Shouldn't trigger assertionFailure in Store.init with error: Error Domain=NSCocoaErrorDomain Code=134060 "A Core Data error occurred." UserInfo={reason=The fetched object at index 2 has an out of order section name 'Middle Group. Objects must be sorted by section name'}
        _ = environment.subscribe(getAssignmentGroupsUseCase)
    }

    func testFiltersToGradedAssignments() {
        let groups: [APIAssignmentGroup] = [
            .make(id: "1", name: "Test", position: 1, assignments: [
                .make(assignment_group_id: "1", grading_type: .points, id: "1", name: "Points", position: 1),
                .make(assignment_group_id: "1", grading_type: .not_graded, id: "2", name: "Not Graded", position: 2)
            ])
        ]
        let result = [GetAssignmentsByGroup.AssignmentGroupsByGradingPeriod(gradingPeriod: nil, assignmentGroups: groups)]

        let useCase = GetAssignmentsByGroup(courseID: "1")
        useCase.write(response: result, urlResponse: nil, to: databaseClient)
        var results = environment.subscribe(useCase)
        XCTAssertEqual(results.all.count, 2)

        let useCaseGradedOnly = GetAssignmentsByGroup(courseID: "1", gradedOnly: true)
        useCaseGradedOnly.write(response: result, urlResponse: nil, to: databaseClient)
        results = environment.subscribe(useCaseGradedOnly)
        XCTAssertEqual(results.all.count, 1)
    }

    func testFetchFiltersAssignmentsByUserID() {
        let assignment1 = APIAssignment.make(
            id: "assignment1",
            name: "Assignment 1",
            submission: APISubmission.make(user_id: "user1")
        )
        let assignment2 = APIAssignment.make(
            id: "assignment2",
            name: "Assignment 2",
            submission: APISubmission.make(user_id: "user2")
        )
        let assignmentGroup = APIAssignmentGroup.make(assignments: [assignment1, assignment2])
        let response = [GetAssignmentsByGroup.AssignmentGroupsByGradingPeriod(gradingPeriod: nil, assignmentGroups: [assignmentGroup])]
        let testee = GetAssignmentsByGroup(courseID: "", userID: "user1")
        testee.write(response: response, urlResponse: nil, to: databaseClient)

        // WHEN
        let assignments: [Assignment] = databaseClient.fetch(scope: testee.scope)

        // THEN
        XCTAssertEqual(assignments.count, 1)
        XCTAssertEqual(assignments.first?.id, "assignment1")
    }
}
