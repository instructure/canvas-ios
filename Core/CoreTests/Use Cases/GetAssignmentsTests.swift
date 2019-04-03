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

        let getAssignment = GetAssignment(courseID: "1", assignmentID: "2", include: [.submission])
        try! getAssignment.write(response: apiAssignment, urlResponse: nil, to: databaseClient)

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

        let getAssignment = GetAssignment(courseID: "1", assignmentID: "2", include: [.submission])
        try! getAssignment.write(response: apiAssignment, urlResponse: nil, to: databaseClient)

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

        let getAssignment = GetAssignment(courseID: "1", assignmentID: "2", include: [.submission])
        try! getAssignment.write(response: apiAssignment, urlResponse: nil, to: databaseClient)

        let assignments: [Assignment] = databaseClient.fetch()
        let assignment = assignments.first
        XCTAssertNotNil(assignment?.submission)
        let submission = assignment?.submission
        XCTAssertNil(submission?.latePolicyStatus)
        XCTAssertNil(submission?.pointsDeducted)
    }

    func testItDeletesSubmission() {
        Assignment.make(["id": "1", "courseID": "1", "submission": Submission.make()])
        let preCheckAssignments: [Assignment] = databaseClient.fetch()
        let apiAssignment = APIAssignment.make([
            "id": "1",
            "name": "a",
            "submission": nil,
        ])
        XCTAssertEqual(apiAssignment.html_url, preCheckAssignments.first?.htmlURL)
        XCTAssertEqual((databaseClient.fetch() as [Submission]).count, 1)

        let getAssignment = GetAssignment(courseID: "1", assignmentID: "1", include: [.submission])
        try! getAssignment.write(response: apiAssignment, urlResponse: nil, to: databaseClient)

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

        let getAssignment = GetAssignment(courseID: "1", assignmentID: "1", include: [])
        try! getAssignment.write(response: apiAssignment, urlResponse: nil, to: databaseClient)

        databaseClient.refresh()
        let submissions: [Submission] = databaseClient.fetch()
        XCTAssertEqual(submissions.count, 0)
    }

    func testDoesntDeleteSubmissionWithoutInclude() {
        Assignment.make(["id": "1", "submission": Submission.make()])
        let preCheckAssignments: [Assignment] = databaseClient.fetch()
        let apiAssignment = APIAssignment.make([
            "id": "1",
            "submission": nil,
        ])
        XCTAssertEqual(apiAssignment.html_url, preCheckAssignments.first?.htmlURL)
        XCTAssertEqual((databaseClient.fetch() as [Submission]).count, 1)

        let getAssignment = GetAssignment(courseID: "1", assignmentID: "1", include: [])
        try! getAssignment.write(response: apiAssignment, urlResponse: nil, to: databaseClient)

        databaseClient.refresh()
        let submissions: [Submission] = databaseClient.fetch()
        XCTAssertEqual(submissions.count, 1)
    }

    func testGetAssignmentsList() {
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
        let getAssignments = GetAssignments(courseID: "1")
        try! getAssignments.write(response: [apiAssignment], urlResponse: nil, to: databaseClient)

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

    func testSortOrderByDueDate2() {
        let dateC = Date().addDays(2)
        let dateD = Date().addDays(3)

        let aa = APIAssignment.make([ "id": "2", "course_id": "1", "due_at": nil])
        let bb = APIAssignment.make([ "id": "3", "course_id": "1", "due_at": nil])
        let cc = APIAssignment.make([ "id": "4", "course_id": "1", "due_at": dateC, "name": "aaa"])
        let dd = APIAssignment.make([ "id": "5", "course_id": "1", "due_at": dateD, "name": "ccc"])
        let ee = APIAssignment.make([ "id": "6", "course_id": "1", "due_at": nil])
        let ff = APIAssignment.make([ "id": "7", "course_id": "1", "due_at": dateD, "name": "bbb"])

        let a = Assignment.make(["id": "2"])
        let b = Assignment.make(["id": "3"])
        let c = Assignment.make(["id": "4"])
        let d = Assignment.make(["id": "5"])
        let e = Assignment.make(["id": "6"])
        let f = Assignment.make(["id": "7"])

       //   must do this so dueAtOrder property gets updated
        try? a.update(fromApiModel: aa, in: databaseClient, updateSubmission: false)
        try? b.update(fromApiModel: bb, in: databaseClient, updateSubmission: false)
        try? c.update(fromApiModel: cc, in: databaseClient, updateSubmission: false)
        try? d.update(fromApiModel: dd, in: databaseClient, updateSubmission: false)
        try? e.update(fromApiModel: ee, in: databaseClient, updateSubmission: false)
        try? f.update(fromApiModel: ff, in: databaseClient, updateSubmission: false)

        let useCase = GetAssignments(courseID: "1", sort: .dueAt)

        let assignments: [Assignment] = databaseClient.fetch(predicate: nil, sortDescriptors: useCase.scope.order)
        XCTAssertEqual(assignments.count, 6)
        let order = assignments.map { "\($0.id)" }.joined(separator: " ")
        //  we don't care about the order of the nil values so trim them at the end of the array
        XCTAssertEqual([c, f, d], Array(assignments[0..<3]), order)
    }

    func testSortOrderPosition() {
        let a = Assignment.make(["position": 3, "id": "2"])
        let b = Assignment.make(["position": 1, "id": "3"])
        let c = Assignment.make(["position": 5, "id": "4"])
        let d = Assignment.make(["position": 4, "id": "5"])

        let useCase = GetAssignments(courseID: "1")

        let assignments: [Assignment] = databaseClient.fetch(predicate: nil, sortDescriptors: useCase.scope.order)
        XCTAssertEqual(assignments.count, 4)
        XCTAssertEqual([b, a, d, c], assignments)
    }
}
