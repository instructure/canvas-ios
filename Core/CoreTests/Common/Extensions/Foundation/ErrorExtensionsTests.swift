//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import Core
import XCTest
import AVFoundation

class ErrorExtensionsTests: XCTestCase {

    func testFrameLoadInterruptedError() {
        let error: Error = NSError(
            domain: "WebKitErrorDomain",
            code: 102
        )
        XCTAssertTrue(error.isFrameLoadInterrupted)
    }

    func testForbiddenError() {
        let error: Error = NSError(
            domain: NSError.Constants.domain,
            code: HttpError.forbidden
        )
        XCTAssertTrue(error.isForbidden)
    }

    func testNotFoundError() {
        let error: Error = NSError(
            domain: NSError.Constants.domain,
            code: HttpError.notFound
        )
        XCTAssertTrue(error.isNotFound)
    }

    func testBadRequestError() {
        let error: Error = NSError(
            domain: NSError.Constants.domain,
            code: HttpError.badRequest
        )
        XCTAssertTrue(error.isBadRequest)
    }

    func testSourceTrackMissingError() {
        let error: Error = NSError(
            domain: AVFoundationErrorDomain,
            code: AVError.Code.noSourceTrack.rawValue
        )
        XCTAssertTrue(error.isSourceTrackMissing)
    }

    func test_debugDescription_withDebugError() {
        let error = MockDebugError()
        XCTAssertEqual(error.debugDescription, "Mock debug description")
    }

    func test_debugDescription_withNonDebugError() {
        let error = MockNonDebugError()
        XCTAssertEqual(error.debugDescription, error.localizedDescription)
    }
}

private struct MockNonDebugError: Error {}

private struct MockDebugError: DebugDescriptionProvider {
    var debugDescription: String { "Mock debug description" }
}
