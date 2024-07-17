//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import XCTest
@testable import Core

class DueViewableTests: XCTestCase {

    private enum TestConstants {
        static let date1224 = DateComponents(calendar: .current, year: 2018, month: 12, day: 24).date!
        static let date1225 = DateComponents(calendar: .current, year: 2018, month: 12, day: 25).date!
        static let date1226 = DateComponents(calendar: .current, year: 2018, month: 12, day: 26).date!
    }

    private struct Model: DueViewable {
        let dueAt: Date?
    }

    override func tearDown() {
        Clock.reset()
        super.tearDown()
    }

    func testDueAtNil() {
        XCTAssertEqual(Model(dueAt: nil).dueText, "No Due Date")
        XCTAssertEqual(Model(dueAt: nil).assignmentDueByText, "No Due Date")
    }

    func testDueFuture() {
        Clock.mockNow(TestConstants.date1224)
        let dueAt = TestConstants.date1225
        XCTAssertEqual(Model(dueAt: dueAt).dueText, "Due " + TestConstants.date1225.relativeDateTimeString)
        XCTAssert(Model(dueAt: dueAt).assignmentDueByText.hasPrefix("This assignment is due by "))
    }

    func testDuePast() {
        Clock.mockNow(TestConstants.date1226)
        let dueAt = TestConstants.date1225
        XCTAssertEqual(Model(dueAt: dueAt).dueText, "Due " + TestConstants.date1225.relativeDateTimeString)
        XCTAssert(Model(dueAt: dueAt).assignmentDueByText.hasPrefix("This assignment was due by "))
    }
}
