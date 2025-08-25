//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import XCTest
@testable import Core
import CoreData

class GetAssignmentsTests: CoreTestCase {

    func testGetAssignmentsList() {
        let apiAssignment = APIAssignment.make(
            course_id: "1",
            description: "some description...",
            due_at: nil,
            grading_type: .pass_fail,
            html_url: URL(string: "https://canvas.instructure.com/courses/1/assignments/2")!,
            id: "2",
            name: "Get Assignment Test",
            points_possible: 10,
            position: 0,
            submission: nil,
            submission_types: [ .on_paper, .external_tool ]
        )
        let getAssignments = GetAssignments(courseID: "1")
        getAssignments.write(response: [apiAssignment], urlResponse: nil, to: databaseClient)

        let assignments: [Assignment] = databaseClient.fetch()
        XCTAssertEqual(assignments.count, 1)
        let assignment = assignments.first!
        XCTAssertEqual(assignment.id, "2")
        XCTAssertEqual(assignment.courseID, "1")
        XCTAssertEqual(assignment.name, "Get Assignment Test")
        XCTAssertEqual(assignment.details, "some description...")
        XCTAssertEqual(assignment.pointsPossible, 10)
        XCTAssertNil(assignment.dueAt)
        XCTAssertEqual(assignment.htmlURL?.absoluteString, "https://canvas.instructure.com/courses/1/assignments/2")
        XCTAssertEqual(assignment.gradingType, .pass_fail)
        XCTAssertEqual(assignment.submissionTypes, [.on_paper, .external_tool])
        XCTAssertEqual(assignment.position, 0)
    }

    func testSortOrderByDueDate2() {
        let dateC = Date().addDays(2)
        let dateD = Date().addDays(3)

        let api2 = APIAssignment.make(course_id: "1", due_at: nil, id: "2", name: "api2")
        let api3 = APIAssignment.make(course_id: "1", due_at: nil, id: "3", name: "api3")
        let api4 = APIAssignment.make(course_id: "1", due_at: dateC, id: "4", name: "api4")
        let api5 = APIAssignment.make(course_id: "1", due_at: dateD, id: "5", name: "api5")
        let api6 = APIAssignment.make(course_id: "1", due_at: nil, id: "6", name: "api6")
        let api7 = APIAssignment.make(course_id: "1", due_at: dateD, id: "7", name: "api7")

        let a2 = Assignment.make(from: .make(id: "2"))
        let a3 = Assignment.make(from: .make(id: "3"))
        let a4 = Assignment.make(from: .make(id: "4"))
        let a5 = Assignment.make(from: .make(id: "5"))
        let a6 = Assignment.make(from: .make(id: "6"))
        let a7 = Assignment.make(from: .make(id: "7"))

       //   must do this so dueAtSortNilsAtBottom property gets updated
        a2.update(fromApiModel: api2, in: databaseClient, updateSubmission: false, updateScoreStatistics: false)
        a3.update(fromApiModel: api3, in: databaseClient, updateSubmission: false, updateScoreStatistics: false)
        a4.update(fromApiModel: api4, in: databaseClient, updateSubmission: false, updateScoreStatistics: false)
        a5.update(fromApiModel: api5, in: databaseClient, updateSubmission: false, updateScoreStatistics: false)
        a6.update(fromApiModel: api6, in: databaseClient, updateSubmission: false, updateScoreStatistics: false)
        a7.update(fromApiModel: api7, in: databaseClient, updateSubmission: false, updateScoreStatistics: false)

        let useCase = GetAssignments(courseID: "1", sort: .dueAt)

        let assignments: [Assignment] = databaseClient.fetch(sortDescriptors: useCase.scope.order)
        XCTAssertEqual(assignments.count, 6)
        let order = assignments.map { "\($0.id)" }.joined(separator: " ")
        print("** order: \(order)")
        XCTAssertEqual([a4, a5, a7, a2, a3, a6], assignments, order)
    }

    func testSortOrderPosition() {
        let a = Assignment.make(from: .make(id: "2", position: 3))
        let b = Assignment.make(from: .make(id: "3", position: 1))
        let c = Assignment.make(from: .make(id: "4", position: 5))
        let d = Assignment.make(from: .make(id: "5", position: 4))

        let useCase = GetAssignments(courseID: "1")

        let assignments: [Assignment] = databaseClient.fetch(sortDescriptors: useCase.scope.order)
        XCTAssertEqual(assignments.count, 4)
        XCTAssertEqual([b, a, d, c], assignments)
    }

    func testSortOrderByName() {
        let a = Assignment.make(from: .make(id: "2", name: "A"))
        let b = Assignment.make(from: .make(id: "3", name: "B"))
        let c = Assignment.make(from: .make(id: "4", name: "C"))

        let useCase = GetAssignments(courseID: "1", sort: .name)

        let assignments: [Assignment] = databaseClient.fetch(sortDescriptors: useCase.scope.order)
        XCTAssertEqual(assignments.count, 3)
        XCTAssertEqual([a, b, c], assignments)
    }
}
