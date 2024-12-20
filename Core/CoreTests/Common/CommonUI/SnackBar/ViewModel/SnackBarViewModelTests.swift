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
import CombineSchedulers
import TestsFoundation
import XCTest

class SnackBarViewModelTests: XCTestCase {
    private var testee: SnackBarViewModel!
    private let testScheduler: TestSchedulerOf<DispatchQueue> = DispatchQueue.test

    override func setUp() {
        super.setUp()
        testee = SnackBarViewModel(scheduler: testScheduler.eraseToAnyScheduler())
    }

    func testSnackPresentation() {
        // MARK: GIVEN
        XCTAssertNil(testee.visibleSnack)

        // MARK: WHEN
        testee.showSnack("test1")
        testee.showSnack("test2")
        testee.showSnack("test3")

        // MARK: THEN
        XCTAssertEqual(testee.visibleSnack, "test1")
        testScheduler.advance(by: .seconds(testee.onScreenTime + testee.animationTime))
        XCTAssertEqual(testee.visibleSnack, nil)
        testee.snackDidDisappear()

        XCTAssertEqual(testee.visibleSnack, "test2")
        testScheduler.advance(by: .seconds(testee.onScreenTime + testee.animationTime))
        XCTAssertEqual(testee.visibleSnack, nil)
        testee.snackDidDisappear()

        XCTAssertEqual(testee.visibleSnack, "test3")
        testScheduler.advance(by: .seconds(testee.onScreenTime + testee.animationTime))
        XCTAssertEqual(testee.visibleSnack, nil)
    }

    func testEquals() {
        // MARK: GIVEN
        let testee1 = SnackBarViewModel()
        let testee2 = SnackBarViewModel()

        // MARK: WHEN
        testee1.showSnack("test")
        testee2.showSnack("test")

        // MARK: THEN
        XCTAssertEqual(testee1, testee2)
    }

    func testNotEquals() {
        // MARK: GIVEN
        let testee1 = SnackBarViewModel()
        let testee2 = SnackBarViewModel()

        // MARK: WHEN
        testee1.showSnack("test")
        testee2.showSnack("not_test")

        // MARK: THEN
        XCTAssertNotEqual(testee1, testee2)
    }

    func testSwallowsDuplicatedSnacks() {
        // MARK: GIVEN
        testee.showSnack("test")
        testee.showSnack("test", swallowDuplicatedSnacks: true)

        // MARK: WHEN
        testee.snackDidDisappear()

        // MARK: THEN
        XCTAssertNil(testee.visibleSnack)
    }

    func testNotSwallowsDuplicatedSnacks() {
        // MARK: GIVEN
        testee.showSnack("test")
        testee.showSnack("test", swallowDuplicatedSnacks: false)

        // MARK: WHEN
        testee.snackDidDisappear()

        // MARK: THEN
        XCTAssertEqual(testee.visibleSnack, "test")
    }

    func testNotSwallowsDuplicatedSnacksByDefault() {
        // MARK: GIVEN
        testee.showSnack("test")
        testee.showSnack("test")

        // MARK: WHEN
        testee.snackDidDisappear()

        // MARK: THEN
        XCTAssertEqual(testee.visibleSnack, "test")
    }

    func testSwallowedSnackExtendsOnScreenTime() {
        // MARK: GIVEN
        testee.showSnack("test")
        // Some time passed but we didn't reach disappearance
        testScheduler.advance(by: .seconds(testee.onScreenTime + testee.animationTime - 0.1))

        // MARK: WHEN
        testee.showSnack("test", swallowDuplicatedSnacks: true)
        testScheduler.advance(by: .seconds(0.2))

        // MARK: THEN
        XCTAssertEqual(testee.visibleSnack, "test")

        // MARK: WHEN
        testScheduler.advance(by: .seconds(testee.onScreenTime + testee.animationTime))

        // MARK: THEN
        XCTAssertEqual(testee.visibleSnack, nil)
    }
}
