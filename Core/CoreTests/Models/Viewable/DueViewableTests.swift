//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
        XCTAssertEqual(Model(dueAt: dueAt).dueText, "Dec 25, 2018 at 12:00 AM")
        XCTAssert(Model(dueAt: dueAt).assignmentDueByText.hasPrefix("This assignment is due by "))
    }

    func testDuePast() {
        Clock.mockNow(DateComponents(calendar: Calendar.current, year: 2018, month: 12, day: 26).date!)
        let dueAt = DateComponents(calendar: Calendar.current, year: 2018, month: 12, day: 25).date
        XCTAssertEqual(Model(dueAt: dueAt).dueText, "Dec 25, 2018 at 12:00 AM")
        XCTAssert(Model(dueAt: dueAt).assignmentDueByText.hasPrefix("This assignment was due by "))
    }
}
