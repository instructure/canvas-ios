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
        let dueDate = Date(fromISOString: "3024-02-16T14:00:00Z")!

        let testData: [(beforeTime: DateComponents, expectedTriggerDate: String)] = [
            (.init(minute: 15), "3024-02-16T13:45:00Z"),
            (.init(hour: 1), "3024-02-16T13:00:00Z"),
            (.init(day: 1), "3024-02-15T14:00:00Z"),
            (.init(weekOfMonth: 1), "3024-02-09T14:00:00Z"),
            (.init(weekOfMonth: 7), "3023-12-29T14:00:00Z")
        ]

        for testEntry in testData {
            let testee = try! UNCalendarNotificationTrigger(assignmentDueDate: dueDate,
                                                            beforeTime: testEntry.beforeTime,
                                                            currentDate: .distantPast)
            let expectedTriggerDate = Date(fromISOString: testEntry.expectedTriggerDate)!
            XCTAssertEqual(testee.nextTriggerDate(), expectedTriggerDate, "beforeTime: \(testEntry.beforeTime)")
        }
    }
}
