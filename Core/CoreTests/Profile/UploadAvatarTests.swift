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

@testable import Core
import XCTest
import TestsFoundation

class UploadAvatarTests: CoreTestCase {
    let error = NSError.instructureError("Oops")
    let url = Bundle(for: UploadAvatarTests.self).url(forResource: "TestImage", withExtension: "png")!

    func result() -> Result<URL, Error> {
        let complete = expectation(description: "complete")
        var value: Result<URL, Error>!
        UploadAvatar(url: url).fetch { result in
            value = result
            complete.fulfill()
        }
        wait(for: [complete], timeout: 1)
        return value
    }

    func testGetTargetError() {
        api.mock(PostFileUploadTargetRequest(context: .myFiles, body: .init(name: "", on_duplicate: .rename, size: 0)), value: nil)
        switch result() {
        case .success: XCTFail()
        case .failure(let found):
            XCTAssertEqual(found as NSError, NSError.internalError())
        }

        api.mock(PostFileUploadTargetRequest(context: .myFiles, body: .init(name: "", on_duplicate: .rename, size: 0)), error: error)
        switch result() {
        case .success: XCTFail()
        case .failure(let found):
            XCTAssertEqual(found as NSError, error)
        }
    }

    func testUploadError() {
        api.mock(PostFileUploadTargetRequest(context: .myFiles, body: .init(name: "", on_duplicate: .rename, size: 0)), value: .make())
        api.mock(PostFileUploadRequest(fileURL: url, target: .make()), value: nil)
        switch result() {
        case .success: XCTFail()
        case .failure(let found):
            XCTAssertEqual(found as NSError, NSError.internalError())
        }

        api.mock(PostFileUploadRequest(fileURL: url, target: .make()), error: error)
        switch result() {
        case .success: XCTFail()
        case .failure(let found):
            XCTAssertEqual(found as NSError, error)
        }
    }

    func testGetFileError() {
        api.mock(PostFileUploadTargetRequest(context: .myFiles, body: .init(name: "", on_duplicate: .rename, size: 0)), value: .make())
        api.mock(PostFileUploadRequest(fileURL: url, target: .make()), value: .make())
        api.mock(GetFileRequest(context: .currentUser, fileID: "1", include: [.avatar]), value: nil)
        switch result() {
        case .success: XCTFail()
        case .failure(let found):
            XCTAssertEqual(found as NSError, NSError.internalError())
        }

        api.mock(GetFileRequest(context: .currentUser, fileID: "1", include: [.avatar]), error: error)
        switch result() {
        case .success: XCTFail()
        case .failure(let found):
            XCTAssertEqual(found as NSError, error)
        }
    }

    func testPutAvatarError() {
        api.mock(PostFileUploadTargetRequest(context: .myFiles, body: .init(name: "", on_duplicate: .rename, size: 0)), value: .make())
        api.mock(PostFileUploadRequest(fileURL: url, target: .make()), value: .make())
        api.mock(GetFileRequest(context: .currentUser, fileID: "1", include: [.avatar]), value: .make(avatar: .init(token: "t")))
        api.mock(PutUserAvatarRequest(token: "t"), value: nil)
        switch result() {
        case .success: XCTFail()
        case .failure(let found):
            XCTAssertEqual(found as NSError, NSError.internalError())
        }

        api.mock(PutUserAvatarRequest(token: "t"), error: error)
        switch result() {
        case .success: XCTFail()
        case .failure(let found):
            XCTAssertEqual(found as NSError, error)
        }
    }

    func testSuccess() {
        api.mock(PostFileUploadTargetRequest(context: .myFiles, body: .init(name: "", on_duplicate: .rename, size: 0)), value: .make())
        api.mock(PostFileUploadRequest(fileURL: url, target: .make()), value: .make())
        api.mock(GetFileRequest(context: .currentUser, fileID: "1", include: [.avatar]), value: .make(avatar: .init(token: "t")))
        api.mock(PutUserAvatarRequest(token: "t"), value: .make(avatar_url: url))
        XCTAssertEqual(try result().get(), url)
        XCTAssertEqual(environment.currentSession?.userAvatarURL, url)

        XCTAssertNoThrow(UploadAvatar(url: url).callback(.success(url)))
        XCTAssertNoThrow(UploadAvatar(url: url).callback(.failure(error)))
        XCTAssertNoThrow(UploadAvatar(url: url).cancel())
    }
}
