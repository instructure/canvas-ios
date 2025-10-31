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

    func test_TimeComponents_CalculatesCorrectly() {
        let model = TimeSpentWidgetModel(id: "1", courseName: "Math", minutesPerDay: 130)
        XCTAssertEqual(model.minutesPerDay / 60, 2)
        XCTAssertEqual(model.minutesPerDay % 60, 10)
    }

    func test_FormattedTime_OnlyMinutes() {
        let model = TimeSpentWidgetModel(id: "1", courseName: "Math", minutesPerDay: 45)
        let result = model.formattedTime.description
        XCTAssertTrue(result.contains("45"))
        XCTAssertTrue(result.contains("mins"))
    }

    func test_FormattedTime_HoursOnly() {
        let model = TimeSpentWidgetModel(id: "1", courseName: "Physics", minutesPerDay: 120)
        let result = model.formattedTime.description
        XCTAssertTrue(result.contains("2"))
        XCTAssertTrue(result.contains("hrs"))
    }

    func test_FormattedTime_HoursAndMinutes() {
        let model = TimeSpentWidgetModel(id: "1", courseName: "Chemistry", minutesPerDay: 80)
        let result = model.formattedTime.description
        XCTAssertTrue(result.contains("1"))
        XCTAssertTrue(result.contains("hr"))
        XCTAssertTrue(result.contains("20"))
        XCTAssertTrue(result.contains("mins"))
    }

    func test_AccessibilityTimeDescription_HandlesPluralAndSingular() {
        let oneMinute = TimeSpentWidgetModel(id: "1", courseName: "Swift", minutesPerDay: 1)
        XCTAssertEqual(oneMinute.titleAccessibilityLabel.contains("1 minute"), true)

        let oneHour = TimeSpentWidgetModel(id: "2", courseName: "SwiftUI", minutesPerDay: 60)
        XCTAssertEqual(oneHour.titleAccessibilityLabel.contains("1 hour"), true)
    }

    func test_AccessibilityCourseTimeSpent_AllCourses() {
        let model = TimeSpentWidgetModel(id: "-1", courseName: "All", minutesPerDay: 180)
        let label = model.accessibilityCourseTimeSpent
        XCTAssertTrue(label.contains("Time spent for all courses"))
        XCTAssertTrue(label.contains("3 hours"))
    }

    func test_AccessibilityCourseTimeSpent_SingleCourse() {
        let model = TimeSpentWidgetModel(id: "1", courseName: "Biology", minutesPerDay: 135)
        let label = model.accessibilityCourseTimeSpent
        XCTAssertTrue(label.contains("Time spent for course Biology"))
        XCTAssertTrue(label.contains("2 hours 15 minutes"))
    }

    func test_TitleAccessibilityLabel_AllCourses() {
        let model = TimeSpentWidgetModel(id: "-1", courseName: "All", minutesPerDay: 125)
        let label = model.titleAccessibilityLabel
        XCTAssertTrue(label.contains("total time spent"))
        XCTAssertTrue(label.contains("2 hours 5 minutes"))
    }

    func test_TitleAccessibilityLabel_SingleCourse() {
        let model = TimeSpentWidgetModel(id: "123", courseName: "Art", minutesPerDay: 61)
        let label = model.titleAccessibilityLabel
        XCTAssertTrue(label.contains("Art time spent is"))
        XCTAssertTrue(label.contains("1 hour 1 minute"))
    }

    func test_TitleAccessibilityButtonLabel_AllCourses() {
        let model = TimeSpentWidgetModel(id: "-1", courseName: "All", minutesPerDay: 100)
        XCTAssertEqual(model.titleAccessibilityButtonLabel, "total selected")
    }

    func test_TitleAccessibilityButtonLabel_SingleCourse() {
        let model = TimeSpentWidgetModel(id: "1", courseName: "History", minutesPerDay: 40)
        let label = model.titleAccessibilityButtonLabel
        XCTAssertTrue(label.contains("History time spent selected"))
    }

    func test_ZeroMinutes_ReturnsZeroMinutesString() {
        let model = TimeSpentWidgetModel(id: "1", courseName: "Science", minutesPerDay: 0)
        let label = model.titleAccessibilityLabel
        XCTAssertTrue(label.contains("0 minutes"))
    }
}
