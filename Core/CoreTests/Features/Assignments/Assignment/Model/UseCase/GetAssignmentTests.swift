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

import XCTest
@testable import Core
import CoreData

class GetAssignmentTests: CoreTestCase {

    func testItCreatesAssignment() {
        let apiAssignment = APIAssignment.make(
            course_id: "1",
            description: "some description...",
            due_at: nil,
            grading_type: .pass_fail,
            html_url: URL(string: "https://canvas.instructure.com/courses/1/assignments/2")!,
            id: "2",
            lock_at: Date(fromISOString: "2018-11-10T06:59:59Z"),
            name: "Get Assignment Test",
            points_possible: 10,
            position: 0,
            submission: nil,
            submission_types: [ .on_paper, .external_tool ],
            unlock_at: Date(fromISOString: "2018-10-26T06:00:00Z")
        )

        let getAssignment = GetAssignment(courseID: "1", assignmentID: "2", include: [.submission])
        getAssignment.write(response: apiAssignment, urlResponse: nil, to: databaseClient)

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
        XCTAssertEqual(assignment.lockAt, ISO8601DateFormatter().date(from: "2018-11-10T06:59:59Z"))
        XCTAssertEqual(assignment.unlockAt, ISO8601DateFormatter().date(from: "2018-10-26T06:00:00Z"))
    }

    func testItCreatesAssignmentSubmission() {
        let request = GetAssignmentRequest(courseID: "1", assignmentID: "2", include: [.submission])
        let apiAssignment = APIAssignment.make(
            id: "2",
            submission: APISubmission.make(
                assignment_id: "2",
                excused: true,
                grade: "A-",
                late: true,
                late_policy_status: .late,
                missing: true,
                points_deducted: 10,
                score: 97,
                workflow_state: .submitted
            )
        )
        api.mock(request, value: apiAssignment, response: nil, error: nil)

        let getAssignment = GetAssignment(courseID: "1", assignmentID: "2", include: [.submission])
        getAssignment.write(response: apiAssignment, urlResponse: nil, to: databaseClient)

        let assignments: [Assignment] = databaseClient.fetch()
        let assignment = assignments.first
        XCTAssertNotNil(assignment)
        XCTAssertNotNil(assignment?.submission)
        let submission = assignment?.submission
        XCTAssertEqual(submission?.grade, "A-")
        XCTAssertEqual(submission?.late, true)
        XCTAssertEqual(submission?.excused, true)
        XCTAssertEqual(submission?.missing, true)
        XCTAssertEqual(submission?.workflowState, .submitted)
        XCTAssertEqual(submission?.latePolicyStatus, .late)
        XCTAssertEqual(submission?.pointsDeducted, 10)
    }

    func testItCreatesAssignmentSubmissionWithoutLatePolicyStatus() {
        let request = GetAssignmentRequest(courseID: "1", assignmentID: "2", include: [.submission])
        let apiAssignment = APIAssignment.make(
            id: "2",
            submission: APISubmission.make(
                assignment_id: "2",
                late_policy_status: nil,
                points_deducted: nil
            )
        )
        api.mock(request, value: apiAssignment, response: nil, error: nil)

        let getAssignment = GetAssignment(courseID: "1", assignmentID: "2", include: [.submission])
        getAssignment.write(response: apiAssignment, urlResponse: nil, to: databaseClient)

        let assignments: [Assignment] = databaseClient.fetch()
        let assignment = assignments.first
        XCTAssertNotNil(assignment?.submission)
        let submission = assignment?.submission
        XCTAssertNil(submission?.latePolicyStatus)
        XCTAssertNil(submission?.pointsDeducted)
    }

    func testItDeletesSubmission() {
        Assignment.make(from: .make(course_id: "1", id: "1", submission: .make()))
        let preCheckAssignments: [Assignment] = databaseClient.fetch()
        let apiAssignment = APIAssignment.make(
            id: "1",
            name: "a",
            submission: nil
        )
        XCTAssertEqual(apiAssignment.html_url, preCheckAssignments.first?.htmlURL)
        XCTAssertEqual((databaseClient.fetch() as [Submission]).count, 1)

        let getAssignment = GetAssignment(courseID: "1", assignmentID: "1", include: [.submission])
        getAssignment.write(response: apiAssignment, urlResponse: nil, to: databaseClient)

        let submissions: [Submission] = databaseClient.fetch()
        XCTAssertEqual(submissions.count, 0)
        let assignments: [Assignment] = databaseClient.fetch()
        let assignment = assignments.first
        XCTAssertNotNil(assignment)
        XCTAssertNil(assignment?.submission)
    }

    func testItDoesntGetSubmission() {
        Assignment.make(from: .make(id: "1", submission: nil))
        let apiAssignment = APIAssignment.make(
            id: "1",
            submission: nil
        )

        let getAssignment = GetAssignment(courseID: "1", assignmentID: "1", include: [])
        getAssignment.write(response: apiAssignment, urlResponse: nil, to: databaseClient)

        databaseClient.refresh()
        let submissions: [Submission] = databaseClient.fetch()
        XCTAssertEqual(submissions.count, 0)
    }

    func testDoesntDeleteSubmissionWithoutInclude() {
        Assignment.make(from: .make(id: "1", submission: .make()))
        let preCheckAssignments: [Assignment] = databaseClient.fetch()
        let apiAssignment = APIAssignment.make(
            id: "1",
            submission: nil
        )
        XCTAssertEqual(apiAssignment.html_url, preCheckAssignments.first?.htmlURL)
        XCTAssertEqual((databaseClient.fetch() as [Submission]).count, 1)

        let getAssignment = GetAssignment(courseID: "1", assignmentID: "1", include: [])
        getAssignment.write(response: apiAssignment, urlResponse: nil, to: databaseClient)

        databaseClient.refresh()
        let submissions: [Submission] = databaseClient.fetch()
        XCTAssertEqual(submissions.count, 1)
    }

    // MARK: - Rubrics

    func testItCreatesRubrics() {
        let apiAssignment = APIAssignment.make(
            id: "2",
            rubric: [APIRubricCriterion.make()]
        )

        let getAssignment = GetAssignment(courseID: "1", assignmentID: "2", include: [])
        getAssignment.write(response: apiAssignment, urlResponse: nil, to: databaseClient)

        let assignments: [Assignment] = databaseClient.fetch()
        let assignment = assignments.first
        XCTAssertNotNil(assignment)
        XCTAssertNotNil(assignment?.rubric)
        XCTAssertEqual(assignment?.rubric?.first?.assignmentID, "2")
        XCTAssertNotNil(assignment?.rubric?.first?.ratings?.first)
        XCTAssertEqual(assignment?.rubric?.first?.ratings?.first?.assignmentID, "2")
    }

    func testItChangesRubrics() {
        Assignment.make(from: .make(course_id: "2", id: "2", rubric: [.make(id: "1")]))

        let apiAssignment = APIAssignment.make(
            id: "2",
            rubric: [APIRubricCriterion.make(id: "2")]
        )

        let getAssignment = GetAssignment(courseID: "1", assignmentID: "2", include: [])
        getAssignment.write(response: apiAssignment, urlResponse: nil, to: databaseClient)

        let assignments: [Assignment] = databaseClient.fetch()
        let assignment = assignments.first
        XCTAssertNotNil(assignment)
        XCTAssertNotNil(assignment?.rubric)
        XCTAssertEqual(assignment?.rubric?.first?.id, "2")

        //  make sure old existing rubrics were deleted
        let rubrics: [CDRubricCriterion] = databaseClient.fetch()
        XCTAssertEqual(rubrics.count, 1)
    }

    func testItDeletesRubrics() {
        Assignment.make(from: .make(course_id: "2", id: "2", rubric: [.make()]))

        let apiAssignment = APIAssignment.make(id: "2")

        let getAssignment = GetAssignment(courseID: "1", assignmentID: "2", include: [])
        getAssignment.write(response: apiAssignment, urlResponse: nil, to: databaseClient)

        let assignments: [Assignment] = databaseClient.fetch()
        let assignment = assignments.first
        XCTAssertNotNil(assignment)
        XCTAssertTrue(assignment?.rubric?.isEmpty ?? false)
    }

    func testItDeletesRubricRatings() {
        Assignment.make(from: .make(course_id: "2", id: "2", rubric: [
            .make(ratings: [.make(id: "1")])
        ]))
        var assignments: [Assignment] = databaseClient.fetch()
        var assignment = assignments.first
        XCTAssertNotNil(assignment?.rubric?.first?.ratings?.first)

        let apiAssignment = APIAssignment.make(
            id: "2",
            rubric: [APIRubricCriterion.make(ratings: nil)]
        )

        let getAssignment = GetAssignment(courseID: "1", assignmentID: "2", include: [])
        getAssignment.write(response: apiAssignment, urlResponse: nil, to: databaseClient)

        assignments = databaseClient.fetch()
        assignment = assignments.first
        XCTAssertNotNil(assignment)
        XCTAssertTrue(assignment?.rubric?.first?.ratings?.isEmpty ?? false)
    }

    func testItChangesRatingsCorrectly() {
        Assignment.make(from: .make(course_id: "2", id: "2", rubric: [
            .make(ratings: [.make(id: "1")])
        ]))

        let apiAssignment = APIAssignment.make(
            id: "2",
            rubric: [APIRubricCriterion.make(ratings: [APIRubricRating.make(id: "2")])]
        )

        let getAssignment = GetAssignment(courseID: "1", assignmentID: "2", include: [])
        getAssignment.write(response: apiAssignment, urlResponse: nil, to: databaseClient)

        let assignments: [Assignment] = databaseClient.fetch()
        let assignment = assignments.first
        XCTAssertNotNil(assignment)
        XCTAssertNotNil(assignment?.rubric)
        XCTAssertEqual(assignment?.rubric?.first?.ratings?.first?.id, "2")
        XCTAssertEqual(assignment?.rubric?.first?.ratings?.first?.assignmentID, "2")
        XCTAssertEqual(assignment?.rubric?.first?.ratings?.count, 1)
    }
}
