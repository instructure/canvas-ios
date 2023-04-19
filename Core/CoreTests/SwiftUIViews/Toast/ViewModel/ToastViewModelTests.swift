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

class ToastViewModelTests: XCTestCase {

    func testToastPresentation() {
        // MARK: - GIVEN
        let testee = ToastViewModel()
        XCTAssertNil(testee.visibleToast)

        // MARK: - WHEN
        testee.showToast("test1")
        testee.showToast("test2")
        testee.showToast("test3")

        // MARK: - THEN
        waitUntil(shouldFail: true) { testee.visibleToast == "test1" }
        waitUntil(shouldFail: true) { testee.visibleToast == nil }
        testee.toastDidDisappear()
        waitUntil(shouldFail: true) { testee.visibleToast == "test2" }
        waitUntil(shouldFail: true) { testee.visibleToast == nil }
        testee.toastDidDisappear()
        waitUntil(shouldFail: true) { testee.visibleToast == "test3" }
        waitUntil(shouldFail: true) { testee.visibleToast == nil }
        testee.toastDidDisappear()
        waitUntil(shouldFail: true) { testee.visibleToast == nil }
    }

    func testEquals() {
        // MARK: - GIVEN
        let testee1 = ToastViewModel()
        let testee2 = ToastViewModel()

        // MARK: - WHEN
        testee1.showToast("test")
        testee2.showToast("test")

        // MARK: - THEN
        XCTAssertEqual(testee1, testee2)
    }

    func testNotEquals() {
        // MARK: - GIVEN
        let testee1 = ToastViewModel()
        let testee2 = ToastViewModel()

        // MARK: - WHEN
        testee1.showToast("test")
        testee2.showToast("not_test")

        // MARK: - THEN
        XCTAssertNotEqual(testee1, testee2)
    }
}
