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

@testable import Student
import XCTest

class AssignmentNotificationTriggerTests: XCTestCase {

    func testNotificationDateCalculation() {
        let currentDate = Date()
        let dueDate = currentDate.addDays(2)
        let beforeTime = DateComponents(day: 1)
        let testee = try! UNTimeIntervalNotificationTrigger(assignmentDueDate: dueDate,
                                                       beforeTime: beforeTime,
                                                       currentDate: currentDate)

        guard let triggerDate = testee.nextTriggerDate() else {
            return XCTFail()
        }

        let expectedTriggerDate = Date().addDays(1)
        XCTAssertTrue(expectedTriggerDate.timeIntervalSince(triggerDate) < 1)
        XCTAssertEqual(testee.timeInterval, 86400)
    }
}
