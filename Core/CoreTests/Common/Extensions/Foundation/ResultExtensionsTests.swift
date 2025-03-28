//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

class ResultExtensionsTests: XCTestCase {

    private enum TestConstants {
        static let error = NSError.instructureError("TestError")
    }

    func testSuccess() {
        let testee: Result<Int, NSError> = .success(42)

        XCTAssertEqual(testee.value, 42)
        XCTAssertEqual(testee.error, nil)
        XCTAssertEqual(testee.isSuccess, true)
        XCTAssertEqual(testee.isFailure, false)
    }

    func testFailure() {
        let testee: Result<Int, NSError> = .failure(TestConstants.error)

        XCTAssertEqual(testee.value, nil)
        XCTAssertEqual(testee.error, TestConstants.error)
        XCTAssertEqual(testee.isSuccess, false)
        XCTAssertEqual(testee.isFailure, true)
    }

    func testSuccessVoid() {
        let testee: Result<Void, Error> = .success

        XCTAssertEqual(testee.isSuccess, true)
    }

    func testErrorInitializer() {
        var testee: Result<Void, Error> = .init(error: nil)
        XCTAssertEqual(testee.isSuccess, true)
        XCTAssertNil(testee.error)

        testee = .init(error: TestConstants.error)
        XCTAssertEqual(testee.isFailure, true)
        XCTAssertEqual(testee.error as NSError?, TestConstants.error)
    }
}
