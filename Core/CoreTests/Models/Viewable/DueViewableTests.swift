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
    struct Model: DueViewable {
        let dueAt: Date?
    }

    override func tearDown() {
        Clock.reset()
    }

    func testDueAtNil() {
        XCTAssertEqual(Model(dueAt: nil).dueText, "No Due Date")
        XCTAssertEqual(Model(dueAt: nil).assignmentDueByText, "No Due Date")
    }

    func testDueFuture() {
        Clock.mockNow(DateComponents(calendar: Calendar.current, year: 2018, month: 12, day: 24).date!)
        let dueAt = DateComponents(calendar: Calendar.current, year: 2018, month: 12, day: 25).date
        XCTAssertEqual(Model(dueAt: dueAt).dueText, "Due Dec 25, 2018, 12:00 AM")
        XCTAssert(Model(dueAt: dueAt).assignmentDueByText.hasPrefix("This assignment is due by "))
    }

    func testDuePast() {
        Clock.mockNow(DateComponents(calendar: Calendar.current, year: 2018, month: 12, day: 26).date!)
        let dueAt = DateComponents(calendar: Calendar.current, year: 2018, month: 12, day: 25).date
        XCTAssertEqual(Model(dueAt: dueAt).dueText, "Due Dec 25, 2018, 12:00 AM")
        XCTAssert(Model(dueAt: dueAt).assignmentDueByText.hasPrefix("This assignment was due by "))
    }
}
