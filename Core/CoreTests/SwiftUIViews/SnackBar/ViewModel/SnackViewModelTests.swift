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

@testable import Core
import TestsFoundation
import XCTest

class SnackViewModelTests: XCTestCase {

    func testSnackPresentation() {
        // MARK: - GIVEN
        let testee = SnackBarViewModel()
        XCTAssertNil(testee.visibleSnack)

        // MARK: - WHEN
        testee.showSnack("test1")
        testee.showSnack("test2")
        testee.showSnack("test3")

        // MARK: - THEN
        waitUntil(shouldFail: true) { testee.visibleSnack == "test1" }
        waitUntil(shouldFail: true) { testee.visibleSnack == nil }
        testee.snackDidDisappear()
        waitUntil(shouldFail: true) { testee.visibleSnack == "test2" }
        waitUntil(shouldFail: true) { testee.visibleSnack == nil }
        testee.snackDidDisappear()
        waitUntil(shouldFail: true) { testee.visibleSnack == "test3" }
        waitUntil(shouldFail: true) { testee.visibleSnack == nil }
        testee.snackDidDisappear()
        waitUntil(shouldFail: true) { testee.visibleSnack == nil }
    }

    func testEquals() {
        // MARK: - GIVEN
        let testee1 = SnackBarViewModel()
        let testee2 = SnackBarViewModel()

        // MARK: - WHEN
        testee1.showSnack("test")
        testee2.showSnack("test")

        // MARK: - THEN
        XCTAssertEqual(testee1, testee2)
    }

    func testNotEquals() {
        // MARK: - GIVEN
        let testee1 = SnackBarViewModel()
        let testee2 = SnackBarViewModel()

        // MARK: - WHEN
        testee1.showSnack("test")
        testee2.showSnack("not_test")

        // MARK: - THEN
        XCTAssertNotEqual(testee1, testee2)
    }
}
