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

class GetRecentlyGradedSubmissionsTests: CoreTestCase {
    func testRequestUsesUserID() {
        let useCase = GetRecentlyGradedSubmissions(userID: "1")
        XCTAssertEqual(useCase.request.userID, "1")
    }

    func testItCreatesSubmissionsWithAssignments() {
        let apiSubmission = APISubmission.make(
            id: "1",
            assignment_id: "2",
            assignment: APIAssignment.make(id: "2", submission: nil)
        )

        let useCase = GetRecentlyGradedSubmissions(userID: "1")
        useCase.write(response: [apiSubmission], urlResponse: nil, to: databaseClient)

        let submissions: [Submission] = databaseClient.fetch()
        XCTAssertEqual(submissions.count, 1)
        XCTAssertEqual(submissions[0].id, "1")
        XCTAssertEqual(submissions[0].assignmentID, "2")

        let assignments: [Assignment] = databaseClient.fetch()
        XCTAssertEqual(assignments.count, 1)
        XCTAssertEqual(assignments[0].id, "2")
        XCTAssertEqual(assignments[0].submission, submissions[0])
    }

    func testCache() {
        let useCase = GetRecentlyGradedSubmissions(userID: "self")
        XCTAssertEqual(useCase.cacheKey, "recently-graded-submissions")
    }
}

class CreateSubmissionTests: CoreTestCase {
    func testItCreatesAssignmentSubmission() {
        //  given
        let submissionType = SubmissionType.online_url
        let context = Context(.course, id: "1")
        let url = URL(string: "http://www.instructure.com")!
        let template: APISubmission = APISubmission.make(
            assignment_id: "2",
            grade: "A-",
            score: 97,
            late: true,
            excused: true,
            missing: true,
            workflow_state: .submitted,
            late_policy_status: .late,
            points_deducted: 10
        )

        //  when
        let createSubmission = CreateSubmission(context: context, assignmentID: "1", userID: "1", submissionType: submissionType, url: url)
        createSubmission.write(response: template, urlResponse: nil, to: databaseClient)

        //  then
        let subs: [Submission] = databaseClient.fetch()
        let submission = subs.first
        XCTAssertNotNil(submission)
        XCTAssertEqual(submission?.grade, "A-")
        XCTAssertEqual(submission?.late, true)
        XCTAssertEqual(submission?.excused, true)
        XCTAssertEqual(submission?.missing, true)
        XCTAssertEqual(submission?.workflowState, .submitted)
        XCTAssertEqual(submission?.latePolicyStatus, .late)
        XCTAssertEqual(submission?.pointsDeducted, 10)
    }

    func testItPostsModuleCompletedRequirement() {
        let context = Context(.course, id: "1")
        let request = CreateSubmissionRequest(context: context, assignmentID: "2", body: .init(submission: .init(submission_type: .online_text_entry)))
        api.mock(request, value: nil)
        let expectation = XCTestExpectation(description: "notification")
        var notification: Notification?
        let token = NotificationCenter.default.addObserver(forName: .CompletedModuleItemRequirement, object: nil, queue: nil) {
            notification = $0
            expectation.fulfill()
        }
        let useCase = CreateSubmission(context: context, assignmentID: "2", userID: "3", submissionType: .online_text_entry)
        useCase.makeRequest(environment: environment) { _, _, _ in }
        wait(for: [expectation], timeout: 0.5)
        XCTAssertNotNil(notification)
        XCTAssertEqual(notification?.userInfo?["requirement"] as? ModuleItemCompletionRequirement, .submit)
        XCTAssertEqual(notification?.userInfo?["moduleItem"] as? ModuleItemType, .assignment("2"))
        XCTAssertEqual(notification?.userInfo?["courseID"] as? String, "1")
        NotificationCenter.default.removeObserver(token)
    }

    func testItDoesNotPostModuleCompletedRequirementIfError() {
        let context = Context(.course, id: "1")
        let request = CreateSubmissionRequest(context: context, assignmentID: "2", body: .init(submission: .init(submission_type: .online_text_entry)))
        api.mock(request, error: NSError.instructureError("oops"))
        let expectation = XCTestExpectation(description: "notification")
        expectation.isInverted = true
        let token = NotificationCenter.default.addObserver(forName: .CompletedModuleItemRequirement, object: nil, queue: nil) { _ in
            expectation.fulfill()
        }
        let useCase = CreateSubmission(context: context, assignmentID: "2", userID: "3", submissionType: .online_text_entry)
        useCase.makeRequest(environment: environment) { _, _, _ in }
        wait(for: [expectation], timeout: 0.2)
        NotificationCenter.default.removeObserver(token)
    }
}

class GetSubmissionTest: CoreTestCase {
    func testItCreatesSubmission() {
        let context = Context(.course, id: "1")
        let apiSubmission = APISubmission.make(
            assignment_id: "2",
            user_id: "3"
        )

        let getSubmission = GetSubmission(context: context, assignmentID: "2", userID: "3")
        getSubmission.write(response: apiSubmission, urlResponse: nil, to: databaseClient)

        let submissions: [Submission] = databaseClient.fetch()
        XCTAssertEqual(submissions.count, 1)
        let submission = submissions.first!
        XCTAssertEqual(submission.assignmentID, "2")
        XCTAssertEqual(submission.userID, "3")
    }

    func testItCreatesSubmissionHistory() {
        let context = Context(.course, id: "1")
        let apiSubmission = APISubmission.make(
            assignment_id: "2",
            user_id: "3",
            attempt: 2,
            submission_history: [
                APISubmission.make(assignment_id: "2", user_id: "3", attempt: 2),
                APISubmission.make(assignment_id: "2", user_id: "3", attempt: 1),
            ]
        )
        let getSubmission = GetSubmission(context: context, assignmentID: "2", userID: "3")
        getSubmission.write(response: apiSubmission, urlResponse: nil, to: databaseClient)

        let submissions: [Submission] = databaseClient.fetch()
        XCTAssertEqual(submissions.count, 2)
        let submission = submissions.first!
        XCTAssertEqual(submission.assignmentID, "2")
        XCTAssertEqual(submission.userID, "3")
    }

    func testNoHistoryDoesntDelete() {
        let context = Context(.course, id: "1")
        Submission.make(from: .make(assignment_id: "2", user_id: "3", late: false, attempt: 2))
        Submission.make(from: .make(assignment_id: "2", user_id: "3", attempt: 1))
        let apiSubmission = APISubmission.make(
            assignment_id: "2",
            user_id: "3",
            late: true,
            attempt: 2
        )

        let getSubmission = GetSubmission(context: context, assignmentID: "2", userID: "3")
        getSubmission.write(response: apiSubmission, urlResponse: nil, to: databaseClient)

        let submissions: [Submission] = databaseClient.fetch()
        XCTAssertEqual(submissions.count, 2)
        let submission = submissions.first(where: { $0.attempt == 2 })!
        XCTAssertEqual(submission.assignmentID, "2")
        XCTAssertEqual(submission.userID, "3")
        XCTAssertEqual(submission.late, true)
    }

    func testCacheKey() {
        let getSubmission = GetSubmission(context: .course("1"), assignmentID: "2", userID: "3")
        XCTAssertEqual(getSubmission.cacheKey, "get-1-2-3-submission")
    }

    func testRequest() {
        let getSubmission = GetSubmission(context: .course("1"), assignmentID: "2", userID: "3")
        XCTAssertEqual(getSubmission.request.path, "courses/1/assignments/2/submissions/3")
    }

    func testScope() {
        let getSubmission = GetSubmission(context: .course("1"), assignmentID: "2", userID: "3")
        let scope = Scope(
            predicate: NSPredicate(
                format: "%K == %@ AND %K == %@",
                #keyPath(Submission.assignmentID),
                "2",
                #keyPath(Submission.userID),
                "3"
            ),
            order: [NSSortDescriptor(key: #keyPath(Submission.attempt), ascending: false)]
        )
        XCTAssertEqual(getSubmission.scope, scope)
    }
}
