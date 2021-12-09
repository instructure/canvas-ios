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

class GetAssignmentsByGroupTests: CoreTestCase {
    func testProperties() {
        let useCase = GetAssignmentsByGroup(courseID: "1", gradingPeriodID: "2")
        XCTAssertEqual(useCase.cacheKey, "courses/1/assignment_groups?grading_period_id=2")
        XCTAssertEqual(useCase.request.courseID, "1")
        XCTAssertEqual(useCase.scope.predicate, NSPredicate(key: #keyPath(Assignment.assignmentGroup.courseID), equals: "1"))
    }

    func testWrite() {
        let useCase = GetAssignmentsByGroup(courseID: "1", gradingPeriodID: "2")
        useCase.write(response: [.make()], urlResponse: nil, to: databaseClient)
        XCTAssertEqual((databaseClient.fetch() as [AssignmentGroup]).count, 1)
        useCase.reset(context: databaseClient)
        XCTAssertEqual((databaseClient.fetch() as [AssignmentGroup]).count, 0)
    }

    func testPredicate() {
        var useCase = GetAssignmentsByGroup(courseID: "1", gradingPeriodID: "2")
        let predicate = NSPredicate(key: #keyPath(Assignment.assignmentGroup.courseID), equals: "1")
        XCTAssertEqual(useCase.scope.predicate, NSPredicate(key: #keyPath(Assignment.assignmentGroup.courseID), equals: "1"))
        useCase = GetAssignmentsByGroup(courseID: "1", gradingPeriodID: "2", gradedOnly: true)
        XCTAssertEqual(useCase.scope.predicate, predicate.and(NSPredicate(format: "%K != %@", #keyPath(Assignment.gradingTypeRaw), "not_graded")))
    }

    func testScope() {
        let useCase = GetAssignmentsByGroup(courseID: "1", gradingPeriodID: "2")
        XCTAssertEqual(useCase.scope, Scope(
            predicate: NSPredicate(key: #keyPath(Assignment.assignmentGroup.courseID), equals: "1"),
            order: [
                NSSortDescriptor(key: #keyPath(Assignment.assignmentGroup.position), ascending: true),
                NSSortDescriptor(key: #keyPath(Assignment.assignmentGroup.name), ascending: true, naturally: true),
                NSSortDescriptor(key: #keyPath(Assignment.dueAtSortNilsAtBottom), ascending: true),
                NSSortDescriptor(key: #keyPath(Assignment.position), ascending: true),
                NSSortDescriptor(key: #keyPath(Assignment.name), ascending: true, naturally: true),
            ],
            sectionNameKeyPath: #keyPath(Assignment.assignmentGroup.position)
        ))
    }

    func testInvalidSectionOrderException() {
        let groups: [APIAssignmentGroup] = [
            .make(id: "9732", name: "Test Assignment Group", position: 1, assignments: [APIAssignment.make(assignment_group_id: "9732", id: "63603", name: "File Upload", position: 1)]),
            .make(id: "9734", name: "Middle Group", position: 2, assignments: [APIAssignment.make(assignment_group_id: "9734", id: "63604", name: "File Upload 2", position: 1)]),
            .make(id: "9733", name: "Test Assignment Group", position: 3, assignments: [APIAssignment.make(assignment_group_id: "9733", id: "63606", name: "File Upload 3", position: 1)]),
        ]

        let getAssignmentGroupsUseCase = GetAssignmentsByGroup(courseID: "20783")
        getAssignmentGroupsUseCase.write(response: groups, urlResponse: nil, to: databaseClient)

        // Shouldn't trigger assertionFailure in Store.init with error: Error Domain=NSCocoaErrorDomain Code=134060 "A Core Data error occurred." UserInfo={reason=The fetched object at index 2 has an out of order section name 'Middle Group. Objects must be sorted by section name'}
        _ = environment.subscribe(getAssignmentGroupsUseCase)
    }

    func testgradesOnly() {
        let groups: [APIAssignmentGroup] = [
            .make(id: "1", name: "Test", position: 1, assignments: [
                APIAssignment.make(assignment_group_id: "1", grading_type: .points, id: "1", name: "Points", position: 1),
                APIAssignment.make(assignment_group_id: "1", grading_type: .not_graded, id: "2", name: "Not Graded", position: 2),
            ]),
        ]

        let useCase = GetAssignmentsByGroup(courseID: "1", gradingPeriodID: "2")
        useCase.write(response: groups, urlResponse: nil, to: databaseClient)
        var results = environment.subscribe(useCase)
        XCTAssertEqual(results.all.count, 2)

        let useCaseGradedOnly = GetAssignmentsByGroup(courseID: "1", gradingPeriodID: "2", gradedOnly: true)
        useCaseGradedOnly.write(response: groups, urlResponse: nil, to: databaseClient)
        results = environment.subscribe(useCaseGradedOnly)
        XCTAssertEqual(results.all.count, 1)
    }
}
