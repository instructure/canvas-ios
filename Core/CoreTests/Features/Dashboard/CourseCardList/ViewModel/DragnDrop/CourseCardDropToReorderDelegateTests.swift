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
import XCTest
import SwiftUI

class CourseCardDropToReorderDelegateTests: XCTestCase {
    private var testee: CourseCardDropToReorderDelegate!
    private var testDelegate: TestCourseCardOrderChangeDelegate!

    override func setUp() {
        super.setUp()
        testDelegate = TestCourseCardOrderChangeDelegate()
        testee = CourseCardDropToReorderDelegate(receiverCardId: "3",
                                                 draggedCourseCardId: .constant("1"),
                                                 order: ["1", "2", "3"],
                                                 delegate: testDelegate!)
    }

    func testDropProposal() {
        XCTAssertEqual(testee.dropUpdated()?.operation, .move)
    }

    func testCallsReorderDidFinishOnPerformDrop() {
        XCTAssertTrue(testee.performDrop())
        XCTAssertTrue(testDelegate.reorderDidFinishCalled)
    }

    func testDropEnteredCalculatesNewOrder() {
        testee.dropEntered()
        XCTAssertEqual(testDelegate.receivedNewOrder, ["2", "3", "1"])
    }
}

class TestCourseCardOrderChangeDelegate: CourseCardOrderChangeDelegate {
    private(set) var reorderDidFinishCalled = false
    private(set) var receivedNewOrder: [CourseCardDropToReorderDelegate.CardID] = []

    func orderDidChange(_ newOrder: [CourseCardDropToReorderDelegate.CardID]) {
        receivedNewOrder = newOrder
    }

    func reorderDidFinish() {
        reorderDidFinishCalled = true
    }
}
