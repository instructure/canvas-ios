//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest
@testable import Core

class GetAssignmentsTests: CoreTestCase {
    func testItCreatesAssignment() {
        let request = GetAssignmentRequest(courseID: "1", assignmentID: "2", include: [.submission])
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
            "position": 0,
            "unlock_at": "2018-10-26T06:00:00Z",
            "lock_at": "2018-11-10T06:59:59Z",
        ])
        api.mock(request, value: apiAssignment, response: nil, error: nil)

        let getAssignment = GetAssignment(courseID: "1", assignmentID: "2", include: [.submission], env: environment)
        addOperationAndWait(getAssignment)

        XCTAssertEqual(getAssignment.errors.count, 0)
        let assignments: [Assignment] = databaseClient.fetch(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(assignments.count, 1)
        let assignment = assignments.first!
        XCTAssertEqual(assignment.id, "2")
        XCTAssertEqual(assignment.courseID, "1")
        XCTAssertEqual(assignment.name, "Get Assignment Test")
        XCTAssertEqual(assignment.details, "some description...")
        XCTAssertEqual(assignment.pointsPossible, 10)
        XCTAssertNil(assignment.dueAt)
        XCTAssertEqual(assignment.htmlURL.absoluteString, "https://canvas.instructure.com/courses/1/assignments/2")
        XCTAssertEqual(assignment.gradingType, .pass_fail)
        XCTAssertEqual(assignment.submissionTypes, [.on_paper, .external_tool])
        XCTAssertEqual(assignment.position, 0)
        XCTAssertEqual(assignment.lockAt, ISO8601DateFormatter().date(from: "2018-11-10T06:59:59Z"))
        XCTAssertEqual(assignment.unlockAt, ISO8601DateFormatter().date(from: "2018-10-26T06:00:00Z"))
    }

    func testItCreatesAssignmentSubmission() {
        let request = GetAssignmentRequest(courseID: "1", assignmentID: "2", include: [.submission])
        let apiAssignment = APIAssignment.make([
            "id": "2",
            "submission": APISubmission.fixture([
                "assignment_id": "2",
                "grade": "A-",
                "score": 97,
                "late": true,
                "excused": true,
                "missing": true,
                "workflow_state": SubmissionWorkflowState.submitted.rawValue,
                "late_policy_status": LatePolicyStatus.late.rawValue,
                "points_deducted": 10,
            ]),
        ])
        api.mock(request, value: apiAssignment, response: nil, error: nil)

        let getAssignment = GetAssignment(courseID: "1", assignmentID: "2", include: [.submission], env: environment)
        addOperationAndWait(getAssignment)

        XCTAssertEqual(getAssignment.errors.count, 0)
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
        let apiAssignment = APIAssignment.make([
            "id": "2",
            "submission": APISubmission.fixture([
                "assignment_id": "2",
                "late_policy_status": nil,
                "points_deducted": nil,
                ]),
            ])
        api.mock(request, value: apiAssignment, response: nil, error: nil)

        let getAssignment = GetAssignment(courseID: "1", assignmentID: "2", include: [.submission], env: environment)
        addOperationAndWait(getAssignment)

        XCTAssertEqual(getAssignment.errors.count, 0)
        let assignments: [Assignment] = databaseClient.fetch()
        let assignment = assignments.first
        XCTAssertNotNil(assignment?.submission)
        let submission = assignment?.submission
        XCTAssertNil(submission?.latePolicyStatus)
        XCTAssertNil(submission?.pointsDeducted)
    }

    func testItDeletesSubmission() {
        Assignment.make(["id": "1", "submission": Submission.make()])
        let apiAssignment = APIAssignment.make([
            "id": "1",
            "submission": nil,
        ])
        XCTAssertEqual((databaseClient.fetch() as [Submission]).count, 1)
        let request = GetAssignmentRequest(courseID: "1", assignmentID: "1", include: [.submission])
        api.mock(request, value: apiAssignment, response: nil, error: nil)

        let getAssignment = GetAssignment(courseID: "1", assignmentID: "1", include: [.submission], env: environment)
        addOperationAndWait(getAssignment)

        databaseClient.refresh()
        let submissions: [Submission] = databaseClient.fetch()
        XCTAssertEqual(submissions.count, 0)
        let assignments: [Assignment] = databaseClient.fetch()
        let assignment = assignments.first
        XCTAssertNotNil(assignment)
        XCTAssertNil(assignment?.submission)
    }

    func testItDoesntGetSubmission() {
        Assignment.make(["id": "1"])
        let apiAssignment = APIAssignment.make([
            "id": "1",
            "submission": nil,
        ])
        let request = GetAssignmentRequest(courseID: "1", assignmentID: "1", include: [])
        api.mock(request, value: apiAssignment, response: nil, error: nil)

        let getAssignment = GetAssignment(courseID: "1", assignmentID: "1", include: [], env: environment)
        addOperationAndWait(getAssignment)

        databaseClient.refresh()
        let submissions: [Submission] = databaseClient.fetch()
        XCTAssertEqual(submissions.count, 0)
    }

    func testDoesntDeleteSubmissionWithoutInclude() {
        Assignment.make(["id": "1", "submission": Submission.make()])
        let apiAssignment = APIAssignment.make([
            "id": "1",
            "submission": nil,
        ])
        XCTAssertEqual((databaseClient.fetch() as [Submission]).count, 1)
        let request = GetAssignmentRequest(courseID: "1", assignmentID: "1", include: [])
        api.mock(request, value: apiAssignment, response: nil, error: nil)

        let getAssignment = GetAssignment(courseID: "1", assignmentID: "1", include: [], env: environment)
        addOperationAndWait(getAssignment)

        databaseClient.refresh()
        let submissions: [Submission] = databaseClient.fetch()
        XCTAssertEqual(submissions.count, 1)
    }

    func testGetAssignmentsList() {
        let request = GetAssignmentsRequest(courseID: "1")
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
            "position": 0,
            ])
        api.mock(request, value: [apiAssignment], response: nil, error: nil)

        let getAssignmentsListUseCase = GetAssignments(courseID: "1", force: true, env: environment)
        addOperationAndWait(getAssignmentsListUseCase)

        XCTAssertEqual(getAssignmentsListUseCase.errors.count, 0)
        let assignments: [Assignment] = databaseClient.fetch(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(assignments.count, 1)
        let assignment = assignments.first!
        XCTAssertEqual(assignment.id, "2")
        XCTAssertEqual(assignment.courseID, "1")
        XCTAssertEqual(assignment.name, "Get Assignment Test")
        XCTAssertEqual(assignment.details, "some description...")
        XCTAssertEqual(assignment.pointsPossible, 10)
        XCTAssertNil(assignment.dueAt)
        XCTAssertEqual(assignment.htmlURL.absoluteString, "https://canvas.instructure.com/courses/1/assignments/2")
        XCTAssertEqual(assignment.gradingType, .pass_fail)
        XCTAssertEqual(assignment.submissionTypes, [.on_paper, .external_tool])
        XCTAssertEqual(assignment.position, 0)
    }
}
