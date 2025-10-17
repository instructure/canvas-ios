//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
@testable import Horizon

final class TimeSpentWidgetModelTests: XCTestCase {
    func testFormattedHoursUnderOneHourSingularAndPlural() {
        let oneMinute = TimeSpentWidgetModel(id: "1", courseName: "Test", minutesPerDay: 1)
        XCTAssertEqual(oneMinute.formattedHours.value, "1")
        XCTAssertTrue(oneMinute.formattedHours.unit.contains("minute"))
        XCTAssertFalse(oneMinute.formattedHours.unit.contains("hours"))

        let fiftyNine = TimeSpentWidgetModel(id: "2", courseName: "Test", minutesPerDay: 59)
        XCTAssertEqual(fiftyNine.formattedHours.value, "59")
        XCTAssertTrue(fiftyNine.formattedHours.unit.contains("minutes"))
    }

    func testFormattedHoursExactlyOneHourAndRounding() {
        let sixty = TimeSpentWidgetModel(id: "1", courseName: "Test", minutesPerDay: 60)
        XCTAssertEqual(sixty.formattedHours.value, "1")
        XCTAssertTrue(sixty.formattedHours.unit.contains("hour"))

        let eightyNine = TimeSpentWidgetModel(id: "2", courseName: "Test", minutesPerDay: 89)
        XCTAssertEqual(eightyNine.formattedHours.value, "1")
        XCTAssertTrue(eightyNine.formattedHours.unit.contains("hour"))

        let ninety = TimeSpentWidgetModel(id: "3", courseName: "Test", minutesPerDay: 90)
        XCTAssertEqual(ninety.formattedHours.value, "2")
        XCTAssertTrue(ninety.formattedHours.unit.contains("hours"))
    }

    func testTitleAccessibilityLabelSingleCourse() {
        let model = TimeSpentWidgetModel(id: "10", courseName: "Biology", minutesPerDay: 30)
        let label = model.titleAccessibilityLabel.lowercased()
        XCTAssertTrue(label.contains("biology"))
        XCTAssertTrue(label.contains("30"))
    }

    func testTitleAccessibilityLabelAllCourses() {
        let aggregate = TimeSpentWidgetModel(id: "-1", courseName: "all courses", minutesPerDay: 120)
        let label = aggregate.titleAccessibilityLabel.lowercased()
        XCTAssertTrue(label.contains("all courses"))
        XCTAssertTrue(label.contains("2") || label.contains("120"))
    }

    func testTitleAccessibilityButtonLabelSingleCourse() {
        let model = TimeSpentWidgetModel(id: "5", courseName: "Chemistry", minutesPerDay: 15)
        let label = model.titleAccessibilityButtonLabel.lowercased()
        XCTAssertTrue(label.contains("chemistry"))
        XCTAssertTrue(label.contains("selected"))
    }

    func testTitleAccessibilityButtonLabelAllCourses() {
        let aggregate = TimeSpentWidgetModel(id: "-1", courseName: "all courses", minutesPerDay: 75)
        let label = aggregate.titleAccessibilityButtonLabel.lowercased()
        XCTAssertTrue(label.contains("all course"))
        XCTAssertTrue(label.contains("selected"))
    }

    func testTotalMinutesPerDayAggregation() {
        let models: [TimeSpentWidgetModel] = [
            .init(id: "1", courseName: "A", minutesPerDay: 10),
            .init(id: "2", courseName: "B", minutesPerDay: 20),
            .init(id: "3", courseName: "C", minutesPerDay: 0)
        ]
        XCTAssertEqual(models.totalMinutesPerDay, 30)
    }
}
