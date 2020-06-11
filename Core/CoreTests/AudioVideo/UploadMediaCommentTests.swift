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

class UploadMediaCommentTests: CoreTestCase {
    let upload = UploadMediaComment(courseID: "1", assignmentID: "2", userID: "3", submissionID: "4", isGroup: false, type: .audio, url: URL(string: "data:text/plain,abcde")!)
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
            body: .init(comment: .init(mediaID: "2", type: upload.type, forGroup: upload.isGroup), submission: nil)
        ), value: nil, error: NSError.internalError())
        upload.putComment(mediaID: "2")
        XCTAssertNotNil(error)
    }

    func testSuccess() {
        let baseURL = URL(string: "https://u.edu/")!
        environment.api = URLSessionAPI(loginSession: nil, urlSession: MockURLSession())
        let api = MockURLSession.self
        api.mock(GetMediaServiceRequest(), value: APIMediaService(domain: "u.edu"))
        api.mock(PostMediaSessionRequest(), value: APIMediaSession(ks: "k"))
        api.mock(PostMediaUploadTokenRequest(body: .init(ks: "k")), data: "<id>t</id>".data(using: .utf8), baseURL: baseURL)
        api.mock(PostMediaUploadRequest(fileURL: upload.url, type: upload.type, ks: "k", token: "t"), value: nil, baseURL: baseURL)
        api.mock(PostMediaIDRequest(ks: "k", token: "t", type: upload.type), data: "<id>2</id>".data(using: .utf8), baseURL: baseURL)
        api.mock(PutSubmissionGradeRequest(
            courseID: upload.courseID,
            assignmentID: upload.assignmentID,
            userID: upload.userID,
            body: .init(comment: .init(mediaID: "2", type: upload.type, forGroup: upload.isGroup), submission: nil)
        ), value: APISubmission.make(
            submission_comments: [ .make() ]
        ))
        let called = self.expectation(description: "callback was called")
        upload.fetch(environment: environment) { comment, error in
            XCTAssertNotNil(comment)
            XCTAssertNil(error)
            called.fulfill()
        }
        wait(for: [called], timeout: 1)
        api.dataMocks = [:]
    }
}
