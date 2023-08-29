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
    typealias DetailsHelper = Helper.Details
    typealias FilterHelper = Helper.Filter

    func testCalendarLayout() {
        // MARK: Seed the usual stuff with a calendar event
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        let event = Helper.createCalendarEvent(course: course)

        // MARK: Get the user logged in, navigate to Calendar
        logInDSUser(student)
        let calendarTab = Helper.TabBar.calendarTab.waitUntil(.visible)
        XCTAssertTrue(calendarTab.isVisible)

        calendarTab.hit()

        // MARK: Check elements of event list
        let navBar = Helper.navBar.waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)

        let todayButton = Helper.todayButton.waitUntil(.visible)
        XCTAssertTrue(todayButton.isVisible)

        let addNoteButton = Helper.addNoteButton.waitUntil(.visible)
        XCTAssertTrue(addNoteButton.isVisible)

        let eventDateButton = Helper.dayButton(event: event).waitUntil(.visible)
        XCTAssertTrue(eventDateButton.isVisible)

        eventDateButton.hit()
        XCTAssertTrue(eventDateButton.waitUntil(.selected).isSelected)

        let eventItem = Helper.eventCell(event: event).waitUntil(.visible)
        XCTAssertTrue(eventItem.isVisible)

        let eventTitleLabel = Helper.titleLabelOfEvent(eventCell: eventItem).waitUntil(.visible)
        XCTAssertTrue(eventTitleLabel.isVisible)
        XCTAssertEqual(eventTitleLabel.label, event.title)

        let eventDateLabel = Helper.dateLabelOfEvent(eventCell: eventItem).waitUntil(.visible)
        XCTAssertTrue(eventDateLabel.isVisible)
        XCTAssertEqual(eventDateLabel.label, Helper.formatDateForDateLabel(event: event))

        let eventCourseLabel = Helper.courseLabelOfEvent(eventCell: eventItem).waitUntil(.visible)
        XCTAssertTrue(eventCourseLabel.isVisible)
        XCTAssertEqual(eventCourseLabel.label, course.name)
    }

    func testCalendarEventDetails() {
        // MARK: Seed the usual stuff with a calendar event
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        let event = Helper.createCalendarEvent(course: course)

        // MARK: Get the user logged in, navigate to Calendar
        logInDSUser(student)
        let calendarTab = Helper.TabBar.calendarTab.waitUntil(.visible)
        XCTAssertTrue(calendarTab.isVisible)

        calendarTab.hit()

        let eventDateButton = Helper.dayButton(event: event).waitUntil(.visible)
        XCTAssertTrue(eventDateButton.isVisible)

        eventDateButton.hit()
        XCTAssertTrue(eventDateButton.waitUntil(.selected).isSelected)

        // MARK: Tap on the event item and check the details
        let eventItem = Helper.eventCell(event: event).waitUntil(.visible)
        XCTAssertTrue(eventItem.isVisible)

        eventItem.hit()
        let titleLabel = DetailsHelper.titleLabel(event: event).waitUntil(.visible)
        XCTAssertTrue(titleLabel.isVisible)

        let dateLabel = DetailsHelper.dateLabel(event: event).waitUntil(.visible)
        XCTAssertTrue(dateLabel.isVisible)

        let locationNameLabel = DetailsHelper.locationNameLabel(event: event).waitUntil(.visible)
        XCTAssertTrue(locationNameLabel.isVisible)

        let locationAddressLabel = DetailsHelper.locationAddressLabel(event: event).waitUntil(.visible)
        XCTAssertTrue(locationAddressLabel.isVisible)

        let descriptionLabel = DetailsHelper.descriptionLabel(event: event).waitUntil(.visible)
        XCTAssertTrue(descriptionLabel.isVisible)
    }

    func testNavigateToEvents() {
        // MARK: Seed the usual stuff with some calendar events
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        let events = Helper.createSampleCalendarEvents(
            course: course,
            eventTypes: [.todays, .tomorrows, .yesterdays, .nextYears])

        // MARK: Get the user logged in, navigate to Calendar
        logInDSUser(student)
        let calendarTab = Helper.TabBar.calendarTab.waitUntil(.visible)
        XCTAssertTrue(calendarTab.isVisible)

        calendarTab.hit()

        // MARK: Navigate to dates and check the events
        let yesterdaysEventItem = Helper.navigateToEvent(event: events.yesterdays!)
        XCTAssertTrue(yesterdaysEventItem.isVisible)

        let todaysEventItem = Helper.navigateToEvent(event: events.todays!)
        XCTAssertTrue(todaysEventItem.isVisible)

        let tomorrowsEventItem = Helper.navigateToEvent(event: events.tomorrows!)
        XCTAssertTrue(tomorrowsEventItem.isVisible)

        let nextYearEventItem = Helper.navigateToEvent(event: events.nextYears!)
        XCTAssertTrue(nextYearEventItem.isVisible)
    }

    func testRecurringEvent() {
        // MARK: Seed the usual stuff with some calendar events
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        let events = Helper.createSampleCalendarEvents(course: course, eventTypes: [.recurring])

        // MARK: Get the user logged in, navigate to Calendar
        logInDSUser(student)
        let calendarTab = Helper.TabBar.calendarTab.waitUntil(.visible)
        XCTAssertTrue(calendarTab.isVisible)

        calendarTab.hit()

        // MARK: Navigate to Recurring event and check recurrency
        let recurringEventItem1 = Helper.navigateToEvent(event: events.recurring!)
        let recurringEventTitle1 = Helper.titleLabelOfEvent(eventCell: recurringEventItem1).waitUntil(.visible)
        XCTAssertTrue(recurringEventItem1.isVisible)
        XCTAssertEqual(recurringEventTitle1.label, events.recurring!.title)

        let recurringEventItem2 = Helper.navigateToEvent(event: events.recurring!.duplicates![0].calendar_event)
        let recurringEventTitle2 = Helper.titleLabelOfEvent(eventCell: recurringEventItem2).waitUntil(.visible)
        XCTAssertTrue(recurringEventItem2.isVisible)
        XCTAssertEqual(recurringEventTitle2.label, events.recurring!.duplicates![0].calendar_event.title)

        let recurringEventItem3 = Helper.navigateToEvent(event: events.recurring!.duplicates![1].calendar_event)
        let recurringEventTitle3 = Helper.titleLabelOfEvent(eventCell: recurringEventItem3).waitUntil(.visible)
        XCTAssertTrue(recurringEventItem3.isVisible)
        XCTAssertEqual(recurringEventTitle3.label, events.recurring!.duplicates![1].calendar_event.title)
    }

    func testCourseFilter() {
        // MARK: Seed the usual stuff with 2 course and 2 separate calendar events
        let student = seeder.createUser()
        let course1 = seeder.createCourse()
        sleep(1)
        let course2 = seeder.createCourse()
        seeder.enrollStudent(student, in: course1)
        seeder.enrollStudent(student, in: course2)

        let event1 = Helper.createCalendarEvent(course: course1)
        let event2 = Helper.createCalendarEvent(course: course2)

        // MARK: Get the user logged in, navigate to Calendar
        logInDSUser(student)
        let calendarTab = Helper.TabBar.calendarTab.waitUntil(.visible)
        XCTAssertTrue(calendarTab.isVisible)

        calendarTab.hit()

        // MARK: Check events
        var eventItem1 = Helper.navigateToEvent(event: event1).waitUntil(.visible)
        var eventItem2 = Helper.navigateToEvent(event: event2).waitUntil(.visible)
        XCTAssertTrue(eventItem1.isVisible)
        XCTAssertTrue(eventItem2.isVisible)

        // MARK: Check course filtering
        let filterButton = Helper.filterButton.waitUntil(.visible)
        XCTAssertTrue(filterButton.isVisible)

        filterButton.hit()

        let filterNavBar = FilterHelper.navBar.waitUntil(.visible)
        XCTAssertTrue(filterNavBar.isVisible)

        let doneButton = FilterHelper.doneButton.waitUntil(.visible)
        XCTAssertTrue(doneButton.isVisible)

        let courseCell1 = FilterHelper.courseCell(course: course1).waitUntil(.visible)
        XCTAssertTrue(courseCell1.isVisible)
        XCTAssertTrue(courseCell1.waitUntil(.selected).isSelected)

        let courseCell2 = FilterHelper.courseCell(course: course2).waitUntil(.visible)
        XCTAssertTrue(courseCell2.isVisible)
        XCTAssertTrue(courseCell2.waitUntil(.selected).isSelected)

        // MARK: Change filter to first course
        courseCell1.actionUntilElementCondition(action: .tap, condition: .selected, gracePeriod: 2)
        courseCell2.actionUntilElementCondition(action: .tap, condition: .unselected, gracePeriod: 2)
        XCTAssertTrue(courseCell1.isSelected)
        XCTAssertFalse(courseCell2.isSelected)

        doneButton.hit()
        eventItem1 = Helper.eventCell(event: event1).waitUntil(.visible)
        eventItem2 = Helper.eventCell(event: event2).waitUntil(.vanish)
        XCTAssertTrue(eventItem1.isVisible)
        XCTAssertTrue(eventItem2.isVanished)

        // MARK: Change filter to second course
        filterButton.hit()
        courseCell1.actionUntilElementCondition(action: .tap, condition: .unselected, gracePeriod: 2)
        courseCell2.actionUntilElementCondition(action: .tap, condition: .selected, gracePeriod: 2)
        XCTAssertFalse(courseCell1.isSelected)
        XCTAssertTrue(courseCell2.isSelected)

        doneButton.hit()
        eventItem1 = Helper.eventCell(event: event1).waitUntil(.vanish, gracePeriod: 2)
        eventItem2 = Helper.eventCell(event: event2).waitUntil(.visible, gracePeriod: 2)
        XCTAssertTrue(eventItem1.isVanished)
        XCTAssertTrue(eventItem2.isVisible)

        // MARK: Change filter to no course selected
        filterButton.hit()
        courseCell1.actionUntilElementCondition(action: .tap, condition: .unselected, gracePeriod: 2)
        courseCell2.actionUntilElementCondition(action: .tap, condition: .unselected, gracePeriod: 2)
        XCTAssertFalse(courseCell1.isSelected)
        XCTAssertFalse(courseCell2.isSelected)

        doneButton.hit()
        eventItem1 = Helper.eventCell(event: event1).waitUntil(.vanish, gracePeriod: 2)
        eventItem2 = Helper.eventCell(event: event2).waitUntil(.vanish, gracePeriod: 2)
        XCTAssertTrue(eventItem1.isVanished)
        XCTAssertTrue(eventItem2.isVanished)
    }
}
