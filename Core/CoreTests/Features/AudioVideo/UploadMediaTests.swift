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

import Foundation
import XCTest
@testable import Core

class UploadMediaTests: CoreTestCase {
    lazy var upload = UploadMedia(type: .audio, url: URL(string: "data:text/plain,abcde")!)
    var comment: SubmissionComment?
    var error: Error?
    var called: XCTestExpectation?

    override func setUp() {
        super.setUp()
        UUID.mock("zzxxzz")
        upload.mediaAPI = API()
        upload.callback = { [weak self] _, error in
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
        upload.fetch(upload.callback)
        XCTAssert(upload.env === environment)
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

    func testCompleteUploadSuccess() {
        let context = Context(.course, id: "1")
        let expectation = XCTestExpectation(description: "callback was called")
        let response = PostCompleteMediaUploadRequest.Response(media_object: .init(media_id: "10"))
        api.mock(PostCompleteMediaUploadRequest(mediaID: "1", context: context, type: .audio), value: response)
        var error: Error?
        var mediaID: String?
        let upload = UploadMedia(type: .audio, url: URL(string: "data:text/plain,abcde")!, context: context)
        upload.callback = {
            mediaID = $0
            error = $1
            expectation.fulfill()
        }
        upload.completeUpload(mediaID: "10")
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(mediaID, "10")
        XCTAssertNil(error)
    }

    func testCompleteUploadError() {
        let context = Context(.course, id: "1")
        let expectation = XCTestExpectation(description: "callback was called")
        api.mock(PostCompleteMediaUploadRequest(mediaID: "1", context: context, type: .audio), error: NSError.internalError())
        var error: Error?
        var mediaID: String?
        let upload = UploadMedia(type: .audio, url: URL(string: "data:text/plain,abcde")!, context: context)
        upload.callback = {
            mediaID = $0
            error = $1
            expectation.fulfill()
        }
        upload.completeUpload(mediaID: "10")
        wait(for: [expectation], timeout: 1)
        XCTAssertNil(mediaID)
        XCTAssertNotNil(error)
    }

    func testCompleteUploadNoContext() {
        let context = Context(.course, id: "1")
        let expectation = XCTestExpectation(description: "callback was called")
        let response = PostCompleteMediaUploadRequest.Response(media_object: .init(media_id: "1"))
        api.mock(PostCompleteMediaUploadRequest(mediaID: "1", context: context, type: .audio), value: response)
        var error: Error?
        var mediaID: String?
        let upload = UploadMedia(type: .audio, url: URL(string: "data:text/plain,abcde")!, context: nil)
        upload.callback = {
            mediaID = $0
            error = $1
            expectation.fulfill()
        }
        upload.completeUpload(mediaID: "2")
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(mediaID, "2")
        XCTAssertNil(error)
    }
}
