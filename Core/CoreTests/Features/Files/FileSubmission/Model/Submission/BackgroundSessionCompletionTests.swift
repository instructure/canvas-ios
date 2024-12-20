//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

class BackgroundSessionCompletionTests: XCTestCase {

    func testCallbackOnMainThread() {
        // MARK: - GIVEN
        let testee = BackgroundSessionCompletion()
        let callbackExpectation = expectation(description: "Callback called")
        testee.callback = {
            callbackExpectation.fulfill()
            XCTAssertEqual(Thread.main, Thread.current)
        }

        // MARK: - WHEN
        testee.backgroundOperationsFinished()

        // MARK: - THEN
        waitForExpectations(timeout: 0.1)
        XCTAssertNil(testee.callback)
    }

    func testMethodReturnsWhenNoCallbackAvailable() {
        // MARK: - GIVEN
        let testee = BackgroundSessionCompletion()

        // MARK: - THEN
        testee.backgroundOperationsFinished()
    }
}
