//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
