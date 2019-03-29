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

    override func setUp() {
        super.setUp()
        UUID.mock("zzxxzz")
        upload.mediaAPI = api
        upload.fetch(environment: environment) { [weak self] (comment, error) in
            self?.comment = comment
            self?.error = error
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
        upload.savePlaceholder()
        XCTAssertNotNil(error)
    }

    func testUpload() {
        api.mock(GetMediaServiceRequest(), error: NSError.internalError())
        upload.upload()
        XCTAssertNotNil(error)

        api.mock(GetMediaServiceRequest(), value: APIMediaService(domain: "u.edu"))
        upload.upload()
        XCTAssertEqual(upload.mediaAPI?.baseURL.absoluteString, "https://u.edu")
    }

    func testGetSessionError() {
        api.mock(PostMediaSessionRequest(), error: NSError.internalError())
        upload.getSession()
        XCTAssertNotNil(error)
    }

    func testGetUploadTokenError() {
        api.mock(PostMediaUploadTokenRequest(body: .init(ks: "k")), error: NSError.internalError())
        upload.getUploadToken(ks: "k")
        XCTAssertNotNil(error)
    }

    func testPostUploadError() {
        api.mock(PostMediaUploadRequest(fileURL: upload.url, type: upload.type, ks: "k", token: "t"), error: NSError.internalError())
        upload.postUpload(ks: "k", token: "t")
        XCTAssertNotNil(error)
    }

    func testGetMediaIDError() {
        api.mock(PostMediaIDRequest(ks: "k", token: "t", type: upload.type), error: NSError.internalError())
        upload.getMediaID(ks: "k", token: "t")
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
        upload.getSession()
        XCTAssertNil(error)
    }
}
