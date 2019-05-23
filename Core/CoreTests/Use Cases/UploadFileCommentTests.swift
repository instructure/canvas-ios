//
// Copyright (C) 2019-present Instructure, Inc.
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
import TestsFoundation

class UploadFileCommentTests: CoreTestCase {
    let upload = UploadFileComment(courseID: "1", assignmentID: "2", userID: "3", submissionID: "4", isGroup: false, batchID: "5")
    let uploader = MockFileUploader()
    var comment: SubmissionComment?
    var error: Error?
    var called: XCTestExpectation?

    override func setUp() {
        super.setUp()
        UUID.mock("zzxxzz")
        upload.env = environment
        upload.callback = { [weak self] (comment, error) in
            self?.comment = comment
            self?.error = error
            self?.called?.fulfill()
        }
        upload.uploadBatch.uploader = uploader
    }

    override func tearDown() {
        UUID.reset()
        super.tearDown()
    }

    func testCancel() {
        XCTAssertNoThrow(upload.cancel())
    }

    func testFetch() {
        upload.fetch(environment: environment, upload.callback)
        XCTAssert(upload.env === environment)
    }

    func testSavePlaceholderError() {
        upload.env = AppEnvironment()
        called = expectation(description: "callback called")
        upload.savePlaceholder()
        wait(for: [called!], timeout: 5)
        XCTAssertNotNil(error)
    }

    func testPutCommentError() {
        api.mock(PutSubmissionGradeRequest(
            courseID: upload.courseID,
            assignmentID: upload.assignmentID,
            userID: upload.userID,
            body: .init(comment: .init(fileIDs: ["2"], forGroup: upload.isGroup), submission: nil)
        ), error: NSError.internalError())
        upload.putComment(fileIDs: ["2"])
        XCTAssertNotNil(error)
    }

    func testUploadError() throws {
        let file = File.make(["id": nil, "batchID": "5"])
        api.mock(PutSubmissionGradeRequest(
            courseID: upload.courseID,
            assignmentID: upload.assignmentID,
            userID: upload.userID,
            body: .init(comment: .init(fileIDs: ["2"], forGroup: upload.isGroup), submission: nil)
        ), value: APISubmission.make([
            "submission_comments": [ APISubmissionComment.fixture() ],
        ]))
        let called = self.expectation(description: "error callback was called")
        called.assertForOverFulfill = false
        upload.fetch(environment: environment) { comment, error in
            XCTAssertNil(comment)
            XCTAssertNotNil(error)
            called.fulfill()
        }
        file.uploadError = "doh"
        try databaseClient.save()
        wait(for: [called], timeout: 1)
    }

    func testSuccess() throws {
        let file = File.make(["id": nil, "batchID": "5"])
        api.mock(PutSubmissionGradeRequest(
            courseID: upload.courseID,
            assignmentID: upload.assignmentID,
            userID: upload.userID,
            body: .init(comment: .init(fileIDs: ["1"], forGroup: upload.isGroup), submission: nil)
        ), value: APISubmission.make([
            "submission_comments": [ APISubmissionComment.fixture() ],
        ]))
        let called = self.expectation(description: "success callback was called")
        called.assertForOverFulfill = false
        upload.fetch(environment: environment) { comment, error in
            XCTAssertNotNil(comment)
            XCTAssertNil(error)
            called.fulfill()
        }
        file.id = "1"
        try databaseClient.save()
        wait(for: [called], timeout: 1)
    }
}
