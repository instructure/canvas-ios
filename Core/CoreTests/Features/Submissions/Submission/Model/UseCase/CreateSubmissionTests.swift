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

    private var testAnalyticsHandler: MockAnalyticsHandler!

    override func setUp() {
        super.setUp()
        testAnalyticsHandler = MockAnalyticsHandler()
        Analytics.shared.handler = testAnalyticsHandler
    }

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

    func test_analytics_success() {
        let context = Context(.course, id: "1")
        let request = CreateSubmissionRequest(
            context: context,
            assignmentID: "2",
            body: .init(submission: .init(group_comment: nil, submission_type: .online_text_entry))
        )

        api.mock(request, value: .make(
            assignment_id: "2",
            attempt: 2
        ))

        let useCase = CreateSubmission(context: context, assignmentID: "2", userID: "3", submissionType: .online_text_entry)
        useCase.makeRequest(environment: environment) { _, _, _ in }

        XCTAssertEqual(testAnalyticsHandler.lastEvent, "submit_textEntry_succeeded")
        XCTAssertEqual(testAnalyticsHandler.lastEventParameter("attempt"), 2)
    }

    func test_analytics_failure() {
        let context = Context(.course, id: "1")
        let request = CreateSubmissionRequest(
            context: context,
            assignmentID: "4",
            body: .init(submission: .init(group_comment: nil, submission_type: .online_url))
        )

        let prevSubmission = Submission(context: databaseClient)
        prevSubmission.userID = "3"
        prevSubmission.assignmentID = "4"
        prevSubmission.attempt = 16

        api.mock(request, error: NSError.instructureError("Random error"))

        let useCase = CreateSubmission(context: context, assignmentID: "4", userID: "3", submissionType: .online_url)
        useCase.makeRequest(environment: environment) { _, _, _ in }

        // Datebase client exhaust
        let exp = expectation(description: "context exhaust")
        databaseClient.perform { exp.fulfill() }
        wait(for: [exp])

        XCTAssertEqual(testAnalyticsHandler.lastEvent, "submit_url_failed")
        XCTAssertEqual(testAnalyticsHandler.lastEventParameter("attempt"), 17)
    }

    func test_analytics_media_recording_params() {
        let context = Context(.course, id: "1")
        let request = CreateSubmissionRequest(
            context: context,
            assignmentID: "34",
            body: .init(
                submission: .init(
                    group_comment: nil,
                    submission_type: .media_recording,
                    media_comment_id: "567",
                    media_comment_type: .video
                )
            )
        )

        api.mock(request, value: .make(
            assignment_id: "34",
            attempt: 6
        ))

        let useCase = CreateSubmission(
            context: context,
            assignmentID: "34",
            userID: "76",
            submissionType: .media_recording,
            mediaCommentID: "34",
            mediaCommentType: .video,
            mediaCommentSource: .camera
        )

        useCase.makeRequest(environment: environment) { _, _, _ in }

        XCTAssertEqual(testAnalyticsHandler.lastEvent, "submit_mediaRecording_succeeded")
        XCTAssertEqual(testAnalyticsHandler.lastEventParameter("attempt"), 6)
        XCTAssertEqual(testAnalyticsHandler.lastEventParameter("media_type"), "video")
        XCTAssertEqual(testAnalyticsHandler.lastEventParameter("media_source"), "camera")
    }

    func test_analytics_studio() {
        let context = Context(.course, id: "1")
        let request = CreateSubmissionRequest(
            context: context,
            assignmentID: "12",
            body: .init(
                submission: .init(
                    group_comment: nil,
                    submission_type: .basic_lti_launch,
                    url: URL(string: "https://canvas.com/path/to/studio/media")
                )
            )
        )

        api.mock(request, value: .make(
            assignment_id: "12",
            attempt: 13
        ))

        let useCase = CreateSubmission(
            context: context,
            assignmentID: "12",
            userID: "4",
            submissionType: .basic_lti_launch,
            url: URL(string: "https://canvas.com/path/to/studio/media")
        )

        useCase.makeRequest(environment: environment) { _, _, _ in }

        XCTAssertEqual(testAnalyticsHandler.lastEvent, "submit_studio_succeeded")
        XCTAssertEqual(testAnalyticsHandler.lastEventParameter("attempt"), 13)
    }
}
