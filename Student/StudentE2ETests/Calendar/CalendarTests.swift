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
    typealias Helper = CalendarHelper
    typealias DetailsHelper = Helper.EventDetails
    typealias FilterHelper = Helper.Filter

    func testCalendarLayout() {
        // Seed
        let (student, course) = Helper.createStudentEnrolledInCourse()
        let event = Helper.createCalendarEvent(course: course)

        // Log in, navigate to entry point
        logInDSUser(student)
        Helper.navigateToCalendarTab()

        // MARK: Check elements of event list
        let navBar = Helper.navBar.waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)

        let todayButton = Helper.todayButton.waitUntil(.visible)
        XCTAssertTrue(todayButton.isVisible)

        let addButton = Helper.addButton.waitUntil(.visible)
        XCTAssertTrue(addButton.isVisible)

        let eventDateButton = Helper.dayButton(for: event).waitUntil(.visible)
        XCTAssertTrue(eventDateButton.isVisible)

        eventDateButton.hit()
        XCTAssertTrue(eventDateButton.waitUntil(.selected).isSelected)

        let eventItem = Helper.itemCell(for: event).waitUntil(.visible)
        XCTAssertTrue(eventItem.isVisible)

        let eventTitleLabel = Helper.ItemCell.titleLabel(in: eventItem).waitUntil(.visible)
        XCTAssertTrue(eventTitleLabel.isVisible)
        XCTAssertEqual(eventTitleLabel.label, event.title)

        let eventDateLabel = Helper.ItemCell.dateLabel(in: eventItem).waitUntil(.visible)
        XCTAssertTrue(eventDateLabel.isVisible)
        XCTAssertEqual(eventDateLabel.label, Helper.ItemCell.formattedDate(for: event))

        let eventCourseLabel = Helper.ItemCell.courseLabel(in: eventItem).waitUntil(.visible)
        XCTAssertTrue(eventCourseLabel.isVisible)
        XCTAssertEqual(eventCourseLabel.label, course.name)
    }

    func testCalendarEventDetails() {
        // Seed
        let (student, course) = Helper.createStudentEnrolledInCourse()
        let event = Helper.createCalendarEvent(course: course)

        // Log in, navigate to entry point
        logInDSUser(student)
        Helper.navigateToCalendarTab()

        let eventDateButton = Helper.dayButton(for: event).waitUntil(.visible)
        XCTAssertTrue(eventDateButton.isVisible)

        eventDateButton.hit()
        XCTAssertTrue(eventDateButton.waitUntil(.selected).isSelected)

        // MARK: Tap on the event item and check the details
        let eventItem = Helper.itemCell(for: event).waitUntil(.visible)
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

    func testNavigateToEventCells() {
        // Seed
        let (student, course) = Helper.createStudentEnrolledInCourse()
        let eventTypes: [Helper.EventType] = [.todays, .tomorrows, .yesterdays, .nextYears]
        let events = Helper.createSampleCalendarEvents(course: course, eventTypes: eventTypes)

        // Log in, navigate to entry point
        logInDSUser(student)
        Helper.navigateToCalendarTab()

        // MARK: Navigate to the dates and check the events
        let yesterdaysEventItem = Helper.navigateToItemCell(for: events.yesterdays!)
        XCTAssertTrue(yesterdaysEventItem.isVisible)

        let todaysEventItem = Helper.navigateToItemCell(for: events.todays!)
        XCTAssertTrue(todaysEventItem.isVisible)

        let tomorrowsEventItem = Helper.navigateToItemCell(for: events.tomorrows!)
        XCTAssertTrue(tomorrowsEventItem.isVisible)

        let nextYearEventItem = Helper.navigateToItemCell(for: events.nextYears!)
        XCTAssertTrue(nextYearEventItem.isVisible)
    }

    func testRecurringEvent() {
        // Seed
        let (student, course) = Helper.createStudentEnrolledInCourse()
        let events = Helper.createSampleCalendarEvents(course: course, eventTypes: [.recurring])

        // Log in, navigate to entry point
        logInDSUser(student)
        Helper.navigateToCalendarTab()

        // MARK: Navigate to Recurring event and check recurrency
        let recurringEventItem1 = Helper.navigateToItemCell(for: events.recurring!)
        let recurringEventTitle1 = Helper.ItemCell.titleLabel(in: recurringEventItem1).waitUntil(.visible)
        XCTAssertTrue(recurringEventItem1.isVisible)
        XCTAssertEqual(recurringEventTitle1.label, events.recurring!.title)

        let recurringEventItem2 = Helper.navigateToItemCell(for: events.recurring!.duplicates![0].calendar_event)
        let recurringEventTitle2 = Helper.ItemCell.titleLabel(in: recurringEventItem2).waitUntil(.visible)
        XCTAssertTrue(recurringEventItem2.isVisible)
        XCTAssertEqual(recurringEventTitle2.label, events.recurring!.duplicates![0].calendar_event.title)

        let recurringEventItem3 = Helper.navigateToItemCell(for: events.recurring!.duplicates![1].calendar_event)
        let recurringEventTitle3 = Helper.ItemCell.titleLabel(in: recurringEventItem3).waitUntil(.visible)
        XCTAssertTrue(recurringEventItem3.isVisible)
        XCTAssertEqual(recurringEventTitle3.label, events.recurring!.duplicates![1].calendar_event.title)
    }

    func testEventForAssignment() {
        // Seed
        let (student, course) = Helper.createStudentEnrolledInCourse()
        let assignment = Helper.createAssignmentWithDueDate(course: course)

        // Log in, navigate to entry point
        logInDSUser(student)
        Helper.navigateToCalendarTab()

        // Navigate to cell and check it
        let cell = Helper.navigateToItemCell(for: assignment)
        XCTAssertTrue(cell.isVisible)
        let titleLabel = Helper.ItemCell.titleLabel(in: cell).waitUntil(.visible)
        XCTAssertEqual(titleLabel.label, assignment.name)
    }

    func testCourseFilter() {
        // Seed
        let student = seeder.createUser()
        let courses = seeder.createCourses(count: 2)
        let course1 = courses[0]
        let course2 = courses[1]
        seeder.enrollStudent(student, in: course1)
        seeder.enrollStudent(student, in: course2)

        let event1 = Helper.createCalendarEvent(course: course1)
        let event2 = Helper.createCalendarEvent(course: course2)

        // Log in, navigate to entry point
        logInDSUser(student)
        Helper.navigateToCalendarTab()

        // MARK: Check events
        var eventItem1 = Helper.navigateToItemCell(for: event1)
        var eventItem2 = Helper.navigateToItemCell(for: event2)
        XCTAssertTrue(eventItem1.isVisible)
        XCTAssertTrue(eventItem2.isVisible)

        // MARK: Check course filtering
        let filterButton = Helper.filterButton.waitUntil(.visible)
        XCTAssertTrue(filterButton.isVisible)

        filterButton.hit()

        let filterNavBar = FilterHelper.navBar.waitUntil(.visible)
        XCTAssertTrue(filterNavBar.isVisible)

        let doneButton = FilterHelper.doneButton.waitUntil(.visible)
        let calendarsLabel = FilterHelper.calendarsLabel.waitUntil(.visible)
        let deselectAllButton = FilterHelper.deselectAllButton.waitUntil(.visible)
        XCTAssertTrue(doneButton.isVisible)
        XCTAssertTrue(calendarsLabel.isVisible)
        XCTAssertTrue(deselectAllButton.isVisible)

        let courseCell1 = FilterHelper.courseCell(course: course1).waitUntil(.visible)
        XCTAssertTrue(courseCell1.isVisible)
        XCTAssertEqual(courseCell1.waitUntil(.value(expected: "1")).stringValue, "1")

        let courseCell2 = FilterHelper.courseCell(course: course2).waitUntil(.visible)
        XCTAssertTrue(courseCell2.isVisible)
        XCTAssertEqual(courseCell2.waitUntil(.value(expected: "1")).stringValue, "1")

        // MARK: Change filter to first course
        courseCell1.actionUntilElementCondition(action: .tap, condition: .value(expected: "1"), gracePeriod: 3)
        courseCell2.actionUntilElementCondition(action: .tap, condition: .value(expected: "0"), gracePeriod: 3)
        XCTAssertEqual(courseCell1.stringValue, "1")
        XCTAssertEqual(courseCell2.stringValue, "0")

        doneButton.hit()
        eventItem1 = Helper.itemCell(for: event1).waitUntil(.visible)
        eventItem2 = Helper.itemCell(for: event2).waitUntil(.vanish)
        XCTAssertTrue(eventItem1.isVisible)
        XCTAssertTrue(eventItem2.isVanished)

        // MARK: Change filter to second course
        filterButton.hit()
        courseCell1.actionUntilElementCondition(action: .tap, condition: .value(expected: "0"), gracePeriod: 3)
        courseCell2.actionUntilElementCondition(action: .tap, condition: .value(expected: "1"), gracePeriod: 3)
        XCTAssertEqual(courseCell1.stringValue, "0")
        XCTAssertEqual(courseCell2.stringValue, "1")

        doneButton.hit()
        eventItem1 = Helper.itemCell(for: event1).waitUntil(.vanish, gracePeriod: 3)
        eventItem2 = Helper.itemCell(for: event2).waitUntil(.visible, gracePeriod: 3)
        XCTAssertTrue(eventItem1.isVanished)
        XCTAssertTrue(eventItem2.isVisible)

        // MARK: Change filter to no course selected
        filterButton.hit()
        courseCell1.actionUntilElementCondition(action: .tap, condition: .value(expected: "0"), gracePeriod: 3)
        courseCell2.actionUntilElementCondition(action: .tap, condition: .value(expected: "0"), gracePeriod: 3)
        XCTAssertEqual(courseCell1.stringValue, "0")
        XCTAssertEqual(courseCell2.stringValue, "0")

        doneButton.hit()
        eventItem1 = Helper.itemCell(for: event1).waitUntil(.vanish, gracePeriod: 3)
        eventItem2 = Helper.itemCell(for: event2).waitUntil(.vanish, gracePeriod: 3)
        XCTAssertTrue(eventItem1.isVanished)
        XCTAssertTrue(eventItem2.isVanished)
    }

    // MARK: - Add ToDo

    func testCreateCalendarTodoItemWithCourseSelected() {
        let title = "My dear calendar todo item"
        let description = "Description of my dear calendar todo item."

        // Seed
        let (student, course) = Helper.createStudentEnrolledInCourse()

        // Log in, navigate to entry point
        logInDSUser(student)
        Helper.navigateToCalendarTab()
        Helper.navigateToAddToDoScreen()

        // MARK: Check UI elements
        let cancelButton = Helper.EditToDo.cancelButton.waitUntil(.visible)
        let addButton2 = Helper.EditToDo.addButton.waitUntil(.visible)
        let titleInput = Helper.EditToDo.titleInput.waitUntil(.visible)
        let calendarSelector = Helper.EditToDo.calendarSelector.waitUntil(.visible)
        let datePicker = Helper.EditToDo.datePicker.waitUntil(.visible)
        let timePicker = Helper.EditToDo.timePicker.waitUntil(.visible)
        let detailsInput = Helper.EditToDo.detailsInput.waitUntil(.visible)
        XCTAssertTrue(cancelButton.isVisible)
        XCTAssertTrue(addButton2.isVisible)
        XCTAssertTrue(titleInput.isVisible)
        XCTAssertTrue(calendarSelector.isVisible)
        XCTAssertTrue(datePicker.isVisible)
        XCTAssertTrue(timePicker.isVisible)
        XCTAssertTrue(detailsInput.isVisible)

        // MARK: Fill the form, tap "Done" button
        titleInput.writeText(text: title)
        calendarSelector.hit()
        let backButton = Helper.EditToDo.CalendarSelector.backButton.waitUntil(.visible)
        let courseItem = Helper.EditToDo.CalendarSelector.courseItem(course: course).waitUntil(.visible)
        XCTAssertTrue(backButton.isVisible)
        XCTAssertTrue(courseItem.isVisible)
        XCTAssertTrue(courseItem.isUnselected)

        courseItem.hit()
        XCTAssertTrue(courseItem.waitUntil(.selected).isSelected)

        backButton.hit()
        XCTAssertTrue(datePicker.waitUntil(.visible).isVisible)
        XCTAssertTrue(timePicker.waitUntil(.visible).isVisible)

        timePicker.hit()
        let hourWheel = Helper.EditToDo.DateSelector.hourWheel.waitUntil(.visible)
        let minutesWheel = Helper.EditToDo.DateSelector.minutesWheel.waitUntil(.visible)
        let meridiemWheel = Helper.EditToDo.DateSelector.meridiemWheel.waitUntil(.visible)
        XCTAssertTrue(hourWheel.isVisible)
        XCTAssertTrue(minutesWheel.isVisible)
        XCTAssertTrue(meridiemWheel.isVisible)

        let hourWheelValue = hourWheel.value! as! String
        let meridiemWheelValue = meridiemWheel.value! as! String
        let hour = Int(hourWheelValue.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())!
        let newHourValue = String(hour == 12 ? 1 : hour + 1)
        hourWheel.adjust(toPickerWheelValue: newHourValue)
        meridiemWheel.adjust(toPickerWheelValue: meridiemWheelValue)
        let newHourWheelValue = "\(newHourValue) o’clock"
        XCTAssertEqual(hourWheel.waitUntil(.value(expected: newHourWheelValue)).stringValue, newHourWheelValue)
        XCTAssertEqual(meridiemWheel.waitUntil(.value(expected: meridiemWheelValue)).stringValue, meridiemWheelValue)
        XCTAssertTrue(titleInput.waitUntil(.visible).isVisible)

        titleInput.forceTap()
        XCTAssertTrue(detailsInput.waitUntil(.visible).isVisible)

        detailsInput.writeText(text: description)
        XCTAssertTrue(addButton2.waitUntil(.visible).isVisible)

        // MARK: Check result
        addButton2.hit()
        let calendarEventItem = Helper.itemCell(at: 0).waitUntil(.visible)
        let titleLabel = calendarEventItem.find(label: title, type: .staticText).waitUntil(.visible)
        XCTAssertTrue(calendarEventItem.isVisible)
        XCTAssertTrue(titleLabel.isVisible)
    }

    func testCreateCalendarTodoItemWithoutCourseSelected() {
        let title = "My dear calendar todo item"
        let description = "Description of my dear calendar todo item."

        // Seed
        let student = Helper.createStudentEnrolled()

        // Log in, navigate to entry point
        logInDSUser(student)
        Helper.navigateToCalendarTab()
        Helper.navigateToAddToDoScreen()

        let cancelButton = Helper.EditToDo.cancelButton.waitUntil(.visible)
        let addButton2 = Helper.EditToDo.addButton.waitUntil(.visible)
        let titleInput = Helper.EditToDo.titleInput.waitUntil(.visible)
        let calendarSelector = Helper.EditToDo.calendarSelector.waitUntil(.visible)
        let datePicker = Helper.EditToDo.datePicker.waitUntil(.visible)
        let timePicker = Helper.EditToDo.timePicker.waitUntil(.visible)
        let detailsInput = Helper.EditToDo.detailsInput.waitUntil(.visible)
        XCTAssertTrue(cancelButton.isVisible)
        XCTAssertTrue(addButton2.isVisible)
        XCTAssertTrue(titleInput.isVisible)
        XCTAssertTrue(calendarSelector.isVisible)
        XCTAssertTrue(datePicker.isVisible)
        XCTAssertTrue(timePicker.isVisible)
        XCTAssertTrue(detailsInput.isVisible)

        // MARK: Fill the form, tap "Done" button
        titleInput.writeText(text: title)
        calendarSelector.hit()
        let backButton = Helper.EditToDo.CalendarSelector.backButton.waitUntil(.visible)
        let userItem = Helper.EditToDo.CalendarSelector.userItem(user: student).waitUntil(.visible)
        XCTAssertTrue(backButton.isVisible)
        XCTAssertTrue(userItem.isVisible)
        XCTAssertTrue(userItem.isSelected)

        backButton.hit()
        XCTAssertTrue(datePicker.waitUntil(.visible).isVisible)
        XCTAssertTrue(timePicker.waitUntil(.visible).isVisible)

        timePicker.hit()
        let hourWheel = Helper.EditToDo.DateSelector.hourWheel.waitUntil(.visible)
        let minutesWheel = Helper.EditToDo.DateSelector.minutesWheel.waitUntil(.visible)
        let meridiemWheel = Helper.EditToDo.DateSelector.meridiemWheel.waitUntil(.visible)
        XCTAssertTrue(hourWheel.isVisible)
        XCTAssertTrue(minutesWheel.isVisible)
        XCTAssertTrue(meridiemWheel.isVisible)

        let hourWheelValue = hourWheel.value! as! String
        let meridiemWheelValue = meridiemWheel.value! as! String
        let hour = Int(hourWheelValue.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())!
        let newHourValue = String(hour == 12 ? 1 : hour + 1)
        hourWheel.adjust(toPickerWheelValue: newHourValue)
        meridiemWheel.adjust(toPickerWheelValue: meridiemWheelValue)
        let newHourWheelValue = "\(newHourValue) o’clock"
        XCTAssertEqual(hourWheel.waitUntil(.value(expected: newHourWheelValue)).stringValue, newHourWheelValue)
        XCTAssertEqual(meridiemWheel.waitUntil(.value(expected: meridiemWheelValue)).stringValue, meridiemWheelValue)
        XCTAssertTrue(titleInput.waitUntil(.visible).isVisible)

        titleInput.forceTap()
        XCTAssertTrue(detailsInput.waitUntil(.visible).isVisible)

        detailsInput.writeText(text: description)
        XCTAssertTrue(addButton2.waitUntil(.visible).isVisible)

        // MARK: Check result
        addButton2.hit()
        let calendarEventItem = Helper.itemCell(at: 0).waitUntil(.visible)
        let titleLabel = calendarEventItem.find(label: title, type: .staticText).waitUntil(.visible)
        XCTAssertTrue(calendarEventItem.isVisible)
        XCTAssertTrue(titleLabel.isVisible)
    }

    // MARK: - Edit ToDo

    func testEditCalendarTodoItem() {
        let title = "My dear calendar todo item"
        let newTitle = "My edited todo item"

        // Seed
        let student = Helper.createStudentEnrolled()

        // Log in, navigate to entry point
        logInDSUser(student)
        Helper.navigateToCalendarTab()

        // MARK: Create Calendar Todo Item
        Helper.navigateToAddToDoScreen()
        let addButton = Helper.EditToDo.addButton.waitUntil(.visible)
        let titleInput = Helper.EditToDo.titleInput.waitUntil(.visible)
        XCTAssertTrue(addButton.isVisible)
        XCTAssertTrue(titleInput.isVisible)
        titleInput.writeText(text: title)
        addButton.hit()

        // MARK: Check result
        let calendarEventItem = Helper.itemCell(at: 0).waitUntil(.visible)
        XCTAssertTrue(calendarEventItem.isVisible)
        let titleLabel = calendarEventItem.find(label: title, type: .staticText).waitUntil(.visible)
        XCTAssertTrue(titleLabel.isVisible)

        // MARK: Open the item, Tap kebab button, Check UI elements
        calendarEventItem.hit()
        let kebabButton = Helper.ToDoDetails.kebabButton.waitUntil(.visible)
        XCTAssertTrue(kebabButton.isVisible)

        kebabButton.hit()
        let editButton = Helper.ToDoDetails.More.editButton.waitUntil(.visible)
        let deleteButton = Helper.ToDoDetails.More.deleteButton.waitUntil(.visible)
        XCTAssertTrue(editButton.isVisible)
        XCTAssertTrue(deleteButton.isVisible)

        // MARK: Tap Edit button, check UI elements
        editButton.hit()
        let saveButton = Helper.EditToDo.saveButton.waitUntil(.visible)
        XCTAssertTrue(saveButton.isVisible)
        XCTAssertTrue(saveButton.isDisabled)
        XCTAssertTrue(titleInput.waitUntil(.visible).isVisible)

        XCTAssertTrue(Helper.EditToDo.cancelButton.waitUntil(.visible).isVisible)
        XCTAssertTrue(Helper.EditToDo.calendarSelector.waitUntil(.visible).isVisible)
        XCTAssertTrue(Helper.EditToDo.datePicker.waitUntil(.visible).isVisible)
        XCTAssertTrue(Helper.EditToDo.timePicker.waitUntil(.visible).isVisible)
        XCTAssertTrue(Helper.EditToDo.detailsInput.waitUntil(.visible).isVisible)

        // MARK: Edit the title, Save
        titleInput.cutText()
        titleInput.writeText(text: newTitle)
        saveButton.waitUntil(.enabled)
        XCTAssertTrue(saveButton.isEnabled)

        saveButton.hit()

        // MARK: Check if title label has changed
        let titleElement = app.find(label: newTitle, type: .staticText).waitUntil(.visible)
        XCTAssertTrue(titleElement.isVisible)
    }

    // MARK: - Delete ToDo

    func testDeleteCalendarTodo() {
        // Seed
        let student = Helper.createStudentEnrolled()

        // Log in, navigate to entry point
        logInDSUser(student)
        Helper.navigateToCalendarTab()

        // MARK: Create Calendar Todo Item
        Helper.navigateToAddToDoScreen()
        let addButton = Helper.EditToDo.addButton.waitUntil(.visible)
        let titleInput = Helper.EditToDo.titleInput.waitUntil(.visible)
        XCTAssertTrue(addButton.isVisible)
        XCTAssertTrue(titleInput.isVisible)
        titleInput.writeText(text: "Something")
        addButton.hit()

        // MARK: Check result
        let calendarEventItem = Helper.itemCell(at: 0).waitUntil(.visible)
        XCTAssertTrue(calendarEventItem.isVisible)

        // MARK: Open the item, Tap kebab button, Check UI elements
        calendarEventItem.hit()
        let kebabButton = Helper.ToDoDetails.kebabButton.waitUntil(.visible)
        XCTAssertTrue(kebabButton.isVisible)

        kebabButton.hit()
        let editButton = Helper.ToDoDetails.More.editButton.waitUntil(.visible)
        let deleteButton = Helper.ToDoDetails.More.deleteButton.waitUntil(.visible)
        XCTAssertTrue(editButton.isVisible)
        XCTAssertTrue(deleteButton.isVisible)

        // MARK: Tap Delete button, check appearing options
        deleteButton.hit()
        let deleteTodoText = Helper.ToDoDetails.More.Delete.deleteTodoText.waitUntil(.visible)
        let cancelTodoButton = Helper.ToDoDetails.More.Delete.cancelButton.waitUntil(.visible)
        let deleteTodoButton = Helper.ToDoDetails.More.Delete.deleteButton.waitUntil(.visible)
        XCTAssertTrue(deleteTodoText.isVisible)
        XCTAssertTrue(cancelTodoButton.isVisible)
        XCTAssertTrue(deleteTodoButton.isVisible)

        // MARK: Tap Delete button, check result
        deleteTodoButton.hit()
        let noEventsLabel = Helper.noEventsLabel.waitUntil(.visible)
        XCTAssertTrue(noEventsLabel.isVisible)
    }
}
