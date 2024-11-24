//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
import TestsFoundation

class UploadFileCommentTests: CoreTestCase {

    lazy var destination = SubmissionDestination(courseID: "1", assignmentID: "2", userID: "3")
    lazy var upload = UploadFileComment(
        destination: destination,
        isGroup: false,
        batchID: "5",
        attempt: nil
    )
    var comment: SubmissionComment?
    var error: Error?
    var called: XCTestExpectation?

    override func setUp() {
        super.setUp()
        UUID.mock("zzxxzz")
        upload.callback = { [weak self] (comment, error) in
            self?.comment = comment
            self?.error = error
            self?.called?.fulfill()
        }
    }

    override func tearDown() {
        UUID.reset()
        super.tearDown()
    }

    func testCancel() {
        XCTAssertNoThrow(upload.cancel())
    }

    func testFetch() {
        upload.fetch(upload.callback)
        XCTAssert(upload.env === environment)
    }

    func testSavePlaceholderError() {
        environment.currentSession = nil
        upload.savePlaceholder()
        XCTAssertNotNil(error)
    }

    func testPutCommentError() {
        api.mock(PutSubmissionGradeRequest(
            courseID: destination.courseID,
            assignmentID: destination.assignmentID,
            userID: destination.userID,
            body: .init(comment: .init(fileIDs: ["2"], forGroup: upload.isGroup, attempt: nil), submission: nil)
        ), error: NSError.internalError())
        upload.putComment(fileIDs: ["2"])
        XCTAssertNotNil(error)
    }

    func testUploadError() throws {
        let context = UploadManager.shared.viewContext
        let file = File.make(batchID: "5", removeID: true, session: currentSession, in: context)
        api.mock(PutSubmissionGradeRequest(
            courseID: destination.courseID,
            assignmentID: destination.assignmentID,
            userID: destination.userID,
            body: .init(comment: .init(fileIDs: ["2"], forGroup: upload.isGroup, attempt: nil), submission: nil)
        ), value: APISubmission.make(
            submission_comments: [ APISubmissionComment.make() ]
        ))
        let called = self.expectation(description: "error callback was called")
        called.assertForOverFulfill = false
        upload.fetch { comment, error in
            XCTAssertNil(comment)
            XCTAssertNotNil(error)
            called.fulfill()
        }
        file.uploadError = "doh"
        try context.save()
        wait(for: [called], timeout: 1)
    }

    func testSuccess() throws {
        let context = UploadManager.shared.viewContext
        let file = File.make(batchID: "5", removeID: true, session: currentSession, in: context)
        api.mock(PutSubmissionGradeRequest(
            courseID: destination.courseID,
            assignmentID: destination.assignmentID,
            userID: destination.userID,
            body: .init(comment: .init(fileIDs: ["1"], forGroup: upload.isGroup, attempt: nil), submission: nil)
        ), value: APISubmission.make(
            submission_comments: [ APISubmissionComment.make() ]
        ))
        let called = self.expectation(description: "success callback was called")
        upload.fetch { comment, error in
            XCTAssertNotNil(comment)
            XCTAssertNil(error)
            called.fulfill()
        }
        file.id = "1"
        try context.save()
        wait(for: [called], timeout: 1)
    }

    func testSuccessWithAttemptField() throws {
        lazy var upload = UploadFileComment(
            destination: destination, isGroup: false, batchID: "5", attempt: 19
        )
        let context = UploadManager.shared.viewContext
        let file = File.make(batchID: "5", removeID: true, session: currentSession, in: context)
        api.mock(PutSubmissionGradeRequest(
            courseID: destination.courseID,
            assignmentID: destination.assignmentID,
            userID: destination.userID,
            body: .init(comment: .init(fileIDs: ["1"], forGroup: upload.isGroup, attempt: 19), submission: nil)
        ), value: APISubmission.make(
            submission_comments: [ APISubmissionComment.make(attempt: 19) ]
        ))
        let called = self.expectation(description: "success callback was called")
        upload.fetch { comment, error in
            XCTAssertNotNil(comment)
            XCTAssertNil(error)
            XCTAssertEqual(comment?.attemptFromAPI, 19)
            called.fulfill()
        }
        file.id = "1"
        try context.save()
        wait(for: [called], timeout: 1)
    }
}
