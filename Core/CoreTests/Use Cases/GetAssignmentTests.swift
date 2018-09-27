//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import XCTest
@testable import Core

class GetAssignmentTests: CoreTestCase {
    func testItCreatesAssignment() {
        let request = GetAssignmentRequest(courseID: "1", assignmentID: "2")
        let apiAssignment = APIAssignment.make([
            "id": "2",
            "course_id": "1",
            "name": "Get Assignment Test",
            "description": "some description...",
            "points_possible": 10,
            "due_at": nil,
            "html_url": "https://canvas.instructure.com/courses/1/assignments/2",
            "submission": nil,
            "grading_type": "pass_fail",
            "submission_types": ["on_paper", "external_tool"],
        ])
        api.mock(request, value: apiAssignment, response: nil, error: nil)

        let getAssignment = GetAssignment(courseID: "1", assignmentID: "2", env: environment)
        addOperationAndWait(getAssignment)

        XCTAssertEqual(getAssignment.errors.count, 0)
        let assignments: [Assignment] = db.fetch(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(assignments.count, 1)
        let assignment = assignments.first!
        XCTAssertEqual(assignment.id, "2")
        XCTAssertEqual(assignment.courseID, "1")
        XCTAssertEqual(assignment.name, "Get Assignment Test")
        XCTAssertEqual(assignment.content, "some description...")
        XCTAssertEqual(assignment.pointsPossible, 10)
        XCTAssertNil(assignment.dueAt)
        XCTAssertEqual(assignment.htmlUrl, "https://canvas.instructure.com/courses/1/assignments/2")
        XCTAssertEqual(assignment.gradingType, .pass_fail)
        XCTAssertEqual(assignment.submissionTypes, [.on_paper, .external_tool])
    }

    func testItCreatesAssignmentSubmission() {
        let request = GetAssignmentRequest(courseID: "1", assignmentID: "2")
        let apiAssignment = APIAssignment.make([
            "id": "2",
            "submission": APISubmission.fixture([
                "assignment_id": "2",
                "grade": "A-",
                "score": 97,
                "late": true,
                "excused": true,
                "missing": true,
                "workflow_state": APISubmission.WorkflowState.submitted.rawValue,
                "late_policy_status": APISubmission.LatePolicyStatus.late.rawValue,
                "points_deducted": 10,
            ]),
        ])
        api.mock(request, value: apiAssignment, response: nil, error: nil)

        let getAssignment = GetAssignment(courseID: "1", assignmentID: "2", env: environment)
        addOperationAndWait(getAssignment)

        XCTAssertEqual(getAssignment.errors.count, 0)
        let assignments: [Assignment] = db.fetch()
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
        let request = GetAssignmentRequest(courseID: "1", assignmentID: "2")
        let apiAssignment = APIAssignment.make([
            "id": "2",
            "submission": APISubmission.fixture([
                "assignment_id": "2",
                "late_policy_status": nil,
                "points_deducted": nil,
                ]),
            ])
        api.mock(request, value: apiAssignment, response: nil, error: nil)

        let getAssignment = GetAssignment(courseID: "1", assignmentID: "2", env: environment)
        addOperationAndWait(getAssignment)

        XCTAssertEqual(getAssignment.errors.count, 0)
        let assignments: [Assignment] = db.fetch()
        let assignment = assignments.first
        XCTAssertNotNil(assignment?.submission)
        let submission = assignment?.submission
        XCTAssertNil(submission?.latePolicyStatus)
        XCTAssertNil(submission?.pointsDeducted)
    }

    func testItDeletesSubmission() {
        self.assignment(["id": "1", "submission": submission()])
        let apiAssignment = APIAssignment.make([
            "id": "1",
            "submission": nil,
        ])
        XCTAssertEqual((db.fetch() as [Submission]).count, 1)
        let request = GetAssignmentRequest(courseID: "1", assignmentID: "1")
        api.mock(request, value: apiAssignment, response: nil, error: nil)

        let getAssignment = GetAssignment(courseID: "1", assignmentID: "1", env: environment)
        addOperationAndWait(getAssignment)

        let submissions: [Submission] = db.fetch()
        XCTAssertEqual(submissions.count, 0)
        let assignments: [Assignment] = db.fetch()
        let assignment = assignments.first
        XCTAssertNotNil(assignment)
        XCTAssertNil(assignment?.submission)
    }
}
