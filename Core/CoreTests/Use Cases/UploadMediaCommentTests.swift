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

class UploadMediaCommentTests: CoreTestCase {
    let upload = UploadMediaComment(courseID: "1", assignmentID: "2", userID: "3", submissionID: "4", isGroup: false, type: .audio, url: URL(string: "data:text/plain,abcde")!)
    var comment: SubmissionComment?
    var error: Error?
    var called: XCTestExpectation?

    override func setUp() {
        super.setUp()
        UUID.mock("zzxxzz")
        upload.mediaAPI = api
        upload.env = environment
        upload.callback = { [weak self] (comment, error) in
            self?.comment = comment
            self?.error = error
            self?.called?.fulfill()
        }
    }

    override func tearDown() {
        UUID.reset()
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
            body: .init(comment: .init(mediaID: "2", type: upload.type, forGroup: upload.isGroup), submission: nil)
        ), error: NSError.internalError())
        upload.putComment(mediaID: "2")
        XCTAssertNotNil(error)
    }

    func testSuccess() {
        api.mock(PostMediaSessionRequest(), value: APIMediaSession(ks: "k"))
        api.mock(PostMediaUploadTokenRequest(body: .init(ks: "k")), value: APIMediaIDWrapper(id: "t"))
        api.mock(PostMediaUploadRequest(fileURL: upload.url, type: upload.type, ks: "k", token: "t"))
        api.mock(PostMediaIDRequest(ks: "k", token: "t", type: upload.type), value: APIMediaIDWrapper(id: "2"))
        api.mock(PutSubmissionGradeRequest(
            courseID: upload.courseID,
            assignmentID: upload.assignmentID,
            userID: upload.userID,
            body: .init(comment: .init(mediaID: "2", type: upload.type, forGroup: upload.isGroup), submission: nil)
        ), value: APISubmission.make([
            "submission_comments": [ APISubmissionComment.fixture() ],
        ]))
        upload.fetch(environment: environment) { _, _ in }
        XCTAssertNil(error)
    }
}
