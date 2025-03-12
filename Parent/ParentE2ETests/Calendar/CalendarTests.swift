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
import XCTest

class CalendarTests: E2ETestCase {
    func testCalendar() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let parent = seeder.createUser()
        let course = seeder.createCourse()
        let calendarEvents = CalendarHelper.createSampleCalendarEvents(course: course, eventTypes: [.todays, .tomorrows])
        seeder.enrollStudent(student, in: course)
        seeder.enrollParent(parent, in: course)
        seeder.addObservee(parent: parent, student: student)

        // MARK: Get the user logged in, check course cards
        logInDSUser(parent)

        let calendarTab = CalendarHelper.TabBar.calendarTab.waitUntil(.visible)
        XCTAssertTrue(calendarTab.isVisible)

        // MARK: Navigate to Calendar, check events
        calendarTab.hit()
        let todaysEventCell = CalendarHelper.eventCell(event: calendarEvents.todays!).waitUntil(.visible)
        var titleOfEventCell = todaysEventCell.find(label: calendarEvents.todays!.title, type: .staticText).waitUntil(.visible)
        XCTAssertTrue(todaysEventCell.isVisible)
        XCTAssertTrue(titleOfEventCell.isVisible)

        let tomorrowsEventCell = CalendarHelper.navigateToEvent(event: calendarEvents.tomorrows!)
        titleOfEventCell = tomorrowsEventCell.find(label: calendarEvents.tomorrows!.title, type: .staticText).waitUntil(.visible)
        XCTAssertTrue(tomorrowsEventCell.isVisible)
        XCTAssertTrue(titleOfEventCell.isVisible)

        // MARK: Check event details
        tomorrowsEventCell.hit()
        let titleLabel = CalendarHelper.Details.titleLabel(event: calendarEvents.tomorrows!).waitUntil(.visible)
        let dateLabel = CalendarHelper.Details.dateLabel(event: calendarEvents.tomorrows!, parent: true).waitUntil(.visible)
        let locationNameLabel = CalendarHelper.Details.locationNameLabel(event: calendarEvents.tomorrows!).waitUntil(.visible)
        let locationAddressLabel = CalendarHelper.Details.locationAddressLabel(event: calendarEvents.tomorrows!).waitUntil(.visible)
        let descriptionLabel = CalendarHelper.Details.descriptionLabel(event: calendarEvents.tomorrows!).waitUntil(.visible)
        XCTAssertTrue(titleLabel.isVisible)
        XCTAssertTrue(dateLabel.isVisible)
        XCTAssertTrue(locationNameLabel.isVisible)
        XCTAssertTrue(locationAddressLabel.isVisible)
        XCTAssertTrue(descriptionLabel.isVisible)
    }
}
