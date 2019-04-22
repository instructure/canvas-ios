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

import Foundation
import XCTest
@testable import Core

class UploadMediaTests: CoreTestCase {
    let upload = UploadMedia(type: .audio, url: URL(string: "data:text/plain,abcde")!)
    var comment: SubmissionComment?
    var error: Error?
    var called: XCTestExpectation?

    override func setUp() {
        super.setUp()
        UUID.mock("zzxxzz")
        upload.mediaAPI = api
        upload.env = environment
        upload.callback = { [weak self] (comment, error) in
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
}
