//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

@testable import Core
import XCTest

class FileSubmissionSubmitterTests: CoreTestCase {

    func testSuccessfulSubmissionStateWrittenToSubmissionEntity() {
        // MARK: - GIVEN
        let submission: FileSubmission = databaseClient.insert()
        submission.comment = "testComment"
        submission.courseID = "testCourse"
        submission.assignmentID = "testAssignment"
        // Simulate previously failed attempt
        submission.submissionError = "testError"
        submission.isSubmitted = false

        let item: FileUploadItem = databaseClient.insert()
        item.apiID = "itemAPIID"
        item.fileSubmission = submission

        let requestedSubmission = CreateSubmissionRequest.Body.Submission(text_comment: "testComment",
                                                                          group_comment: nil,
                                                                          submission_type: .online_upload,
                                                                          file_ids: ["itemAPIID"])
        let request = CreateSubmissionRequest(context: .course("testCourse"),
                                              assignmentID: "testAssignment",
                                              body: .init(submission: requestedSubmission))
        api.mock(request, value: APISubmission.make())

        let testee = FileSubmissionSubmitter(api: api, context: databaseClient)
        let completionEvent = expectation(description: "completion event fire")
        let apiResponseEvent = expectation(description: "api response event fire")

        // MARK: - WHEN
        let subscription = testee.submitFiles(fileSubmissionID: submission.objectID).sink { completion in
            if case .finished = completion {
                completionEvent.fulfill()
            }
        } receiveValue: { apiSubmission in
            XCTAssertEqual(apiSubmission, APISubmission.make())
            apiResponseEvent.fulfill()
        }

        // MARK: - THEN
        waitForExpectations(timeout: 0.1)
        XCTAssertNil(submission.submissionError)
        XCTAssertTrue(submission.isSubmitted)
        subscription.cancel()
    }

    func testFailedSubmissionStateWrittenToSubmissionEntity() {
        // MARK: - GIVEN
        let submission: FileSubmission = databaseClient.insert()
        submission.comment = "testComment"
        submission.courseID = "testCourse"
        submission.assignmentID = "testAssignment"
        // Simulate previously suceeded attempt
        submission.submissionError = nil
        submission.isSubmitted = true

        let item: FileUploadItem = databaseClient.insert()
        item.apiID = "itemAPIID"
        item.fileSubmission = submission

        let requestedSubmission = CreateSubmissionRequest.Body.Submission(text_comment: "testComment",
                                                                          group_comment: nil,
                                                                          submission_type: .online_upload,
                                                                          file_ids: ["itemAPIID"])
        let request = CreateSubmissionRequest(context: .course("testCourse"),
                                              assignmentID: "testAssignment",
                                              body: .init(submission: requestedSubmission))
        api.mock(request, value: nil, error: NSError.instructureError("testError"))

        let testee = FileSubmissionSubmitter(api: api, context: databaseClient)
        let completionEvent = expectation(description: "completion event fire")
        let apiResponseEvent = expectation(description: "api response event fire")
        apiResponseEvent.isInverted = true

        // MARK: - WHEN
        let subscription = testee.submitFiles(fileSubmissionID: submission.objectID).sink { completion in
            if case .failure(let error) = completion {
                XCTAssertEqual(error, .submissionFailed)
                completionEvent.fulfill()
            }
        } receiveValue: { _ in
            apiResponseEvent.fulfill()
        }

        // MARK: - THEN
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(submission.submissionError, "testError")
        XCTAssertFalse(submission.isSubmitted)
        subscription.cancel()
    }

    func testStreamFailureIfSubmissionDeletedFromCoreData() {
        // MARK: - GIVEN
        let submission: FileSubmission = databaseClient.insert()
        submission.comment = "testComment"
        submission.courseID = "testCourse"
        submission.assignmentID = "testAssignment"

        let requestedSubmission = CreateSubmissionRequest.Body.Submission(text_comment: "testComment",
                                                                          group_comment: nil,
                                                                          submission_type: .online_upload,
                                                                          file_ids: [])
        let request = CreateSubmissionRequest(context: .course("testCourse"),
                                              assignmentID: "testAssignment",
                                              body: .init(submission: requestedSubmission))
        let mockTask = api.mock(request, value: nil, error: nil)
        mockTask.suspend()

        let testee = FileSubmissionSubmitter(api: api, context: databaseClient)
        let completionEvent = expectation(description: "completion event fire")
        let apiResponseEvent = expectation(description: "api response event fire")
        apiResponseEvent.isInverted = true

        let subscription = testee.submitFiles(fileSubmissionID: submission.objectID).sink { completion in
            if case .failure(let error) = completion {
                XCTAssertEqual(error, .coreData(.submissionNotFound))
                completionEvent.fulfill()
            } else {
                XCTFail()
            }
        } receiveValue: { _ in
            apiResponseEvent.fulfill()
        }

        // MARK: - WHEN
        databaseClient.delete(submission)
        try? databaseClient.save()
        mockTask.resume()

        // MARK: - THEN
        waitForExpectations(timeout: 0.1)
        subscription.cancel()
    }

}
