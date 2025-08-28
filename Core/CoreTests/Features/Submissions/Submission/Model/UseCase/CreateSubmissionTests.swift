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

class CreateSubmissionTests: CoreTestCase {
    func testItCreatesAssignmentSubmission() {
        //  given
        let submissionType = SubmissionType.online_url
        let context = Context(.course, id: "1")
        let url = URL(string: "http://www.instructure.com")!
        let template: APISubmission = APISubmission.make(
            assignment_id: "1",
            excused: true,
            grade: "A-",
            late: true,
            late_policy_status: .late,
            missing: true,
            points_deducted: 10,
            score: 97,
            workflow_state: .submitted
        )

        //  when
        let createSubmission = CreateSubmission(context: context, assignmentID: "1", userID: "1", submissionType: submissionType, url: url)
        createSubmission.write(response: template, urlResponse: nil, to: databaseClient)

        //  then
        let subs: [Submission] = databaseClient.fetch(scope: createSubmission.scope)
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
        let request = CreateSubmissionRequest(context: context, assignmentID: "2", body: .init(submission: .init(group_comment: nil, submission_type: .online_text_entry)))
        api.mock(request, value: nil)
        let expectation = XCTestExpectation(description: "notification")
        let token = NotificationCenter.default.addObserver(forName: .CompletedModuleItemRequirement, object: nil, queue: nil) { notification in
            XCTAssertEqual(notification.userInfo?["requirement"] as? ModuleItemCompletionRequirement, .submit)
            XCTAssertEqual(notification.userInfo?["moduleItem"] as? ModuleItemType, .assignment("2"))
            XCTAssertEqual(notification.userInfo?["courseID"] as? String, "1")
            expectation.fulfill()
        }
        let useCase = CreateSubmission(context: context, assignmentID: "2", userID: "3", submissionType: .online_text_entry)
        useCase.makeRequest(environment: environment) { _, _, _ in }
        wait(for: [expectation], timeout: 0.5)
        NotificationCenter.default.removeObserver(token)
    }

    func testItDoesNotPostModuleCompletedRequirementIfError() {
        let context = Context(.course, id: "1")
        let request = CreateSubmissionRequest(context: context, assignmentID: "2", body: .init(submission: .init(group_comment: nil, submission_type: .online_text_entry)))
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
