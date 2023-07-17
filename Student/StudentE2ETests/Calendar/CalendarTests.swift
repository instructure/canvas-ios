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

import TestsFoundation

class CalendarTests: E2ETestCase {
    typealias Helper = CalendarHelper

    func testCalendarLayout() {
        // MARK: Seed the usual stuff with some calendar events
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        let event = Helper.createCalendarEvent(course: course)

        // MARK: Get the user logged in
        logInDSUser(student)
        let calendarTab = TabBar.calendarTab.waitToExist()
        XCTAssertTrue(calendarTab.isVisible)

        calendarTab.tap()

        let navBar = Helper.navBar.waitToExist()
        XCTAssertTrue(navBar.isVisible)

        let todayButton = Helper.todayButton.waitToExist()
        XCTAssertTrue(todayButton.isVisible)

        let addNoteButton = Helper.addNoteButton.waitToExist()
        XCTAssertTrue(addNoteButton.isVisible)

        let todayDateButton = Helper.dayButton(date: Helper.formatDateForDayButton(date: event.start_at!)).waitToExist()
        XCTAssertTrue(todayDateButton.isVisible)
        XCTAssertTrue(todayDateButton.isSelected)

        let eventItem = Helper.eventCell(event: event).waitToExist()
        XCTAssertTrue(eventItem.isVisible)

        let eventTitleLabel = Helper.titleLabelOfEvent(eventCell: eventItem).waitToExist()
        XCTAssertTrue(eventTitleLabel.isVisible)
        XCTAssertEqual(eventTitleLabel.label(), event.title)

        let eventDateLabel = Helper.dateLabelOfEvent(eventCell: eventItem).waitToExist()
        XCTAssertTrue(eventDateLabel.isVisible)

        let eventCourseLabel = Helper.courseLabelOfEvent(eventCell: eventItem).waitToExist()
        XCTAssertTrue(eventCourseLabel.isVisible)
        XCTAssertEqual(eventCourseLabel.label(), course.name)
    }
}
